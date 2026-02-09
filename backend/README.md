# Finflow Backend (FastAPI)

## Overview
This backend provides a REST API for profile data, transactions, budgets, and AI insights using Gemini. It expects Google OAuth ID tokens for authentication and uses an AI consent header for Gemini requests.

## Database Schema
- users
  - id (PK)
  - email (unique)
  - age
  - is_student
  - monthly_income
  - currency
  - savings_goal
  - created_at

- transactions
  - id (PK)
  - user_id (FK -> users.id)
  - title
  - amount
  - category
  - type (income | expense)
  - date

- budgets
  - id (PK)
  - user_id (FK -> users.id)
  - month (YYYY-MM)
  - monthly_limit
  - rollover_enabled
  - carryover_amount
  - last_rollover_month

- category_budgets
  - id (PK)
  - budget_id (FK -> budgets.id)
  - category
  - limit

- goals
  - id (PK)
  - user_id (FK -> users.id)
  - title
  - target_amount
  - saved_amount
  - target_date

- recurring_templates
  - id (PK)
  - user_id (FK -> users.id)
  - title
  - amount
  - category
  - type
  - day_of_month
  - last_applied_month

## Environment
Create a .env file:

GEMINI_API_KEY=YOUR_KEY
GEMINI_MODEL=gemini-1.5-flash
DATABASE_URL=sqlite:///./finflow.db

## Run locally

pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

## API Summary
- POST /auth/google
- GET/POST /profile
- GET/POST /transactions
- POST /budgets
- GET/POST /goals
- POST /sync
- POST /ai/insights (requires header X-AI-Consent: true)

## Gemini prompts
System prompt:
"You are a personal financial assistant designed for students and young individuals. 
Analyze financial data, identify spending patterns, predict future financial outcomes, 
and provide practical, student-friendly financial advice. 
Use simple language, give actionable suggestions, and encourage healthy financial habits."

User prompt JSON:
{
  "user_age": 21,
  "is_student": true,
  "monthly_income": 1200,
  "expenses": {
    "Food": 240,
    "Rent": 400
  },
  "monthly_budget": 900,
  "savings_goal": 200,
  "historical_data": []
}

## Example AI response
{
  "financial_summary": "You are spending about two thirds of your income, leaving room to save.",
  "spending_analysis": "Rent and food are your biggest costs this month.",
  "key_observations": [
    "Food spending is higher on weekends",
    "Subscriptions are small but steady"
  ],
  "predictions": "If you keep this pace, you will finish the month with about $240 left.",
  "actionable_suggestions": [
    "Set a weekly food limit and track it every Sunday",
    "Pause one subscription for a month"
  ],
  "financial_education_tips": [
    "A simple 50/30/20 split is a helpful starting point",
    "Pay yourself first by moving savings early in the month"
  ]
}
