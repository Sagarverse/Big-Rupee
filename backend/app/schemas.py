from datetime import datetime
from typing import Dict, List, Optional

from pydantic import BaseModel, ConfigDict, Field


class UserProfileIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    age: int
    is_student: bool = Field(alias='isStudent')
    monthly_income: float = Field(alias='monthlyIncome')
    currency: str
    savings_goal: float = Field(alias='savingsGoal')


class UserProfileOut(UserProfileIn):
    email: str


class TransactionIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    title: str
    amount: float
    category: str
    type: str
    date: datetime
    recurring_id: str | None = Field(default=None, alias='recurringId')


class TransactionOut(TransactionIn):
    id: int


class CategoryBudgetIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    category: str
    limit: float


class BudgetIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    month: str
    monthly_limit: float = Field(alias='monthlyLimit')
    categories: List[CategoryBudgetIn] = Field(default_factory=list)
    rollover_enabled: bool = Field(default=False, alias='rolloverEnabled')
    carryover_amount: float = Field(default=0, alias='carryoverAmount')
    last_rollover_month: str = Field(default='', alias='lastRolloverMonth')


class BudgetOut(BudgetIn):
    id: int


class GoalIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    title: str
    target_amount: float = Field(alias='targetAmount')
    saved_amount: float = Field(alias='savedAmount')
    target_date: datetime = Field(alias='targetDate')


class GoalOut(GoalIn):
    id: int


class RecurringTemplateIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    title: str
    amount: float
    category: str
    type: str
    day_of_month: int = Field(alias='dayOfMonth')
    last_applied_month: str = Field(alias='lastAppliedMonth')


class RecurringTemplateOut(RecurringTemplateIn):
    id: int


class AiRequest(BaseModel):
    user_age: int
    is_student: bool
    monthly_income: float
    expenses: Dict[str, float]
    monthly_budget: float
    savings_goal: float
    historical_data: List[dict]


class AiResponse(BaseModel):
    financial_summary: str
    spending_analysis: str
    key_observations: List[str]
    predictions: str
    actionable_suggestions: List[str]
    financial_education_tips: List[str]


class AuthRequest(BaseModel):
    id_token: str


class AuthResponse(BaseModel):
    email: str
    name: Optional[str]


class SyncPayload(BaseModel):
    profile: Optional[UserProfileIn] = None
    budget: Optional[BudgetIn] = None
    goals: List[GoalIn] = Field(default_factory=list)
    transactions: List[TransactionIn] = Field(default_factory=list)
    recurring_templates: List[RecurringTemplateIn] = Field(default_factory=list)
