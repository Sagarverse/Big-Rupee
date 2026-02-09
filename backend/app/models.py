from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from .db import Base


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    age = Column(Integer, default=0)
    is_student = Column(Boolean, default=True)
    monthly_income = Column(Float, default=0)
    currency = Column(String, default='USD')
    savings_goal = Column(Float, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    transactions = relationship('Transaction', back_populates='user', cascade='all, delete')
    budgets = relationship('Budget', back_populates='user', cascade='all, delete')
    goals = relationship('Goal', back_populates='user', cascade='all, delete')
    recurring_templates = relationship(
        'RecurringTemplate', back_populates='user', cascade='all, delete'
    )


class Transaction(Base):
    __tablename__ = 'transactions'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String, nullable=False)
    amount = Column(Float, nullable=False)
    category = Column(String, nullable=False)
    type = Column(String, nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    recurring_id = Column(String, nullable=True)

    user = relationship('User', back_populates='transactions')


class Budget(Base):
    __tablename__ = 'budgets'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    month = Column(String, nullable=False)
    monthly_limit = Column(Float, default=0)
    rollover_enabled = Column(Boolean, default=False)
    carryover_amount = Column(Float, default=0)
    last_rollover_month = Column(String, default='')

    user = relationship('User', back_populates='budgets')
    categories = relationship('CategoryBudget', back_populates='budget', cascade='all, delete')


class Goal(Base):
    __tablename__ = 'goals'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String, nullable=False)
    target_amount = Column(Float, default=0)
    saved_amount = Column(Float, default=0)
    target_date = Column(DateTime, default=datetime.utcnow)

    user = relationship('User', back_populates='goals')


class RecurringTemplate(Base):
    __tablename__ = 'recurring_templates'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String, nullable=False)
    amount = Column(Float, default=0)
    category = Column(String, nullable=False)
    type = Column(String, nullable=False)
    day_of_month = Column(Integer, default=1)
    last_applied_month = Column(String, default='')

    user = relationship('User', back_populates='recurring_templates')


class CategoryBudget(Base):
    __tablename__ = 'category_budgets'

    id = Column(Integer, primary_key=True, index=True)
    budget_id = Column(Integer, ForeignKey('budgets.id'), nullable=False)
    category = Column(String, nullable=False)
    limit = Column(Float, default=0)

    budget = relationship('Budget', back_populates='categories')
