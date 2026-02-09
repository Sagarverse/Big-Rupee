from datetime import datetime

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
from sqlalchemy.orm import Session

from .db import Base, engine, get_db
from .models import (
    Budget,
    CategoryBudget,
    Goal,
    RecurringTemplate,
    Transaction,
    User,
)
from .schemas import (
    AiRequest,
    AiResponse,
    AuthRequest,
    AuthResponse,
    BudgetIn,
    BudgetOut,
    GoalIn,
    GoalOut,
    RecurringTemplateIn,
    TransactionIn,
    TransactionOut,
    UserProfileIn,
    UserProfileOut,
    SyncPayload,
)
from .services.gemini_client import GeminiClient

Base.metadata.create_all(bind=engine)

app = FastAPI(title='Finflow API')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    if not authorization:
        raise HTTPException(status_code=401, detail='Missing auth token')
    token = authorization.replace('Bearer ', '')
    try:
        info = id_token.verify_oauth2_token(token, google_requests.Request())
    except Exception as exc:  # pragma: no cover - auth guard
        raise HTTPException(status_code=401, detail='Invalid token') from exc

    email = info.get('email')
    if not email:
        raise HTTPException(status_code=401, detail='Missing email')

    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(email=email)
        db.add(user)
        db.commit()
        db.refresh(user)
    return user


@app.post('/auth/google', response_model=AuthResponse)
def auth_google(request: AuthRequest) -> AuthResponse:
    info = id_token.verify_oauth2_token(request.id_token, google_requests.Request())
    return AuthResponse(email=info.get('email', ''), name=info.get('name'))


@app.get('/profile', response_model=UserProfileOut)
def get_profile(
    user: User = Depends(get_current_user),
) -> UserProfileOut:
    return UserProfileOut(
        email=user.email,
        age=user.age,
        is_student=user.is_student,
        monthly_income=user.monthly_income,
        currency=user.currency,
        savings_goal=user.savings_goal,
    )


@app.post('/profile', response_model=UserProfileOut)
def update_profile(
    profile: UserProfileIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileOut:
    user.age = profile.age
    user.is_student = profile.is_student
    user.monthly_income = profile.monthly_income
    user.currency = profile.currency
    user.savings_goal = profile.savings_goal
    db.add(user)
    db.commit()
    db.refresh(user)
    return UserProfileOut(email=user.email, **profile.model_dump())


@app.get('/transactions', response_model=list[TransactionOut])
def list_transactions(
    month: str | None = None,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TransactionOut]:
    query = db.query(Transaction).filter(Transaction.user_id == user.id)
    if month:
        start = datetime.strptime(month, '%Y-%m')
        end = datetime(start.year, start.month, 28)
        query = query.filter(Transaction.date >= start, Transaction.date <= end)
    return [
        TransactionOut(
            id=item.id,
            title=item.title,
            amount=item.amount,
            category=item.category,
            type=item.type,
            date=item.date,
            recurring_id=item.recurring_id,
        )
        for item in query.order_by(Transaction.date.desc()).all()
    ]


@app.post('/transactions', response_model=TransactionOut)
def create_transaction(
    payload: TransactionIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TransactionOut:
    item = Transaction(user_id=user.id, **payload.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return TransactionOut(id=item.id, **payload.model_dump())


@app.post('/budgets', response_model=BudgetOut)
def create_budget(
    payload: BudgetIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> BudgetOut:
    budget = Budget(
        user_id=user.id,
        month=payload.month,
        monthly_limit=payload.monthly_limit,
        rollover_enabled=payload.rollover_enabled,
        carryover_amount=payload.carryover_amount,
        last_rollover_month=payload.last_rollover_month,
    )
    db.add(budget)
    db.flush()
    for category in payload.categories:
        db.add(
            CategoryBudget(
                budget_id=budget.id,
                category=category.category,
                limit=category.limit,
            )
        )
    db.commit()
    db.refresh(budget)
    return BudgetOut(
        id=budget.id,
        month=budget.month,
        monthly_limit=budget.monthly_limit,
        rollover_enabled=budget.rollover_enabled,
        carryover_amount=budget.carryover_amount,
        last_rollover_month=budget.last_rollover_month,
        categories=[
            {'category': item.category, 'limit': item.limit} for item in budget.categories
        ],
    )


@app.get('/goals', response_model=list[GoalOut])
def list_goals(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[GoalOut]:
    return [
        GoalOut(
            id=goal.id,
            title=goal.title,
            target_amount=goal.target_amount,
            saved_amount=goal.saved_amount,
            target_date=goal.target_date,
        )
        for goal in db.query(Goal).filter(Goal.user_id == user.id).all()
    ]


@app.post('/goals', response_model=GoalOut)
def create_goal(
    payload: GoalIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> GoalOut:
    goal = Goal(user_id=user.id, **payload.model_dump())
    db.add(goal)
    db.commit()
    db.refresh(goal)
    return GoalOut(id=goal.id, **payload.model_dump())


@app.post('/sync')
def sync_data(
    payload: SyncPayload,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    if payload.profile:
        user.age = payload.profile.age
        user.is_student = payload.profile.is_student
        user.monthly_income = payload.profile.monthly_income
        user.currency = payload.profile.currency
        user.savings_goal = payload.profile.savings_goal

    db.query(Transaction).filter(Transaction.user_id == user.id).delete()
    db.query(Budget).filter(Budget.user_id == user.id).delete()
    db.query(Goal).filter(Goal.user_id == user.id).delete()
    db.query(RecurringTemplate).filter(RecurringTemplate.user_id == user.id).delete()

    for item in payload.transactions:
        db.add(Transaction(user_id=user.id, **item.model_dump()))

    if payload.budget:
        budget = Budget(
            user_id=user.id,
            month=payload.budget.month,
            monthly_limit=payload.budget.monthly_limit,
            rollover_enabled=payload.budget.rollover_enabled,
            carryover_amount=payload.budget.carryover_amount,
            last_rollover_month=payload.budget.last_rollover_month,
        )
        db.add(budget)
        db.flush()
        for category in payload.budget.categories:
            db.add(
                CategoryBudget(
                    budget_id=budget.id,
                    category=category.category,
                    limit=category.limit,
                )
            )

    for item in payload.goals:
        db.add(Goal(user_id=user.id, **item.model_dump()))

    for item in payload.recurring_templates:
        db.add(
            RecurringTemplate(
                user_id=user.id,
                title=item.title,
                amount=item.amount,
                category=item.category,
                type=item.type,
                day_of_month=item.day_of_month,
                last_applied_month=item.last_applied_month,
            )
        )

    db.commit()

    return {
        'profile': {
            'age': user.age,
            'isStudent': user.is_student,
            'monthlyIncome': user.monthly_income,
            'currency': user.currency,
            'savingsGoal': user.savings_goal,
        },
        'budget': payload.budget.model_dump(by_alias=True) if payload.budget else None,
        'goals': [item.model_dump(by_alias=True) for item in payload.goals],
        'transactions': [item.model_dump(by_alias=True) for item in payload.transactions],
        'recurring_templates': [item.model_dump(by_alias=True) for item in payload.recurring_templates],
    }


@app.post('/ai/insights', response_model=AiResponse)
async def ai_insights(
    payload: AiRequest,
    x_ai_consent: str | None = Header(default=None),
) -> AiResponse:
    if x_ai_consent != 'true':
        raise HTTPException(status_code=403, detail='AI consent required')

    client = GeminiClient()
    data = await client.generate_insights(payload.model_dump())
    return AiResponse(
        financial_summary=data.get('financial_summary', ''),
        spending_analysis=data.get('spending_analysis', ''),
        key_observations=data.get('key_observations', []),
        predictions=data.get('predictions', ''),
        actionable_suggestions=data.get('actionable_suggestions', []),
        financial_education_tips=data.get('financial_education_tips', []),
    )
