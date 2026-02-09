import json

import httpx

from ..config import GEMINI_API_KEY, GEMINI_MODEL

SYSTEM_PROMPT = (
    'You are a personal financial assistant designed for students and young individuals. '
    'Analyze financial data, identify spending patterns, predict future financial outcomes, '
    'and provide practical, student-friendly financial advice. '
    'Use simple language, give actionable suggestions, and encourage healthy financial habits.'
)


class GeminiClient:
    def __init__(self) -> None:
        self.base_url = (
            f'https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent'
        )

    async def generate_insights(self, payload: dict) -> dict:
        if not GEMINI_API_KEY:
            raise RuntimeError('GEMINI_API_KEY is missing')

        body = {
            'systemInstruction': {'parts': [{'text': SYSTEM_PROMPT}]},
            'contents': [
                {
                    'role': 'user',
                    'parts': [
                        {
                            'text': (
                                'Respond ONLY with JSON using these keys: '
                                'financial_summary, spending_analysis, key_observations, '
                                'predictions, actionable_suggestions, financial_education_tips.\n\n'
                                f'Data: {json.dumps(payload)}'
                            )
                        }
                    ],
                }
            ],
            'generationConfig': {
                'temperature': 0.4,
                'topP': 0.9,
                'maxOutputTokens': 512,
            },
        }

        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.post(
                self.base_url,
                params={'key': GEMINI_API_KEY},
                json=body,
            )
            response.raise_for_status()
            data = response.json()

        try:
            text = data['candidates'][0]['content']['parts'][0]['text']
            return json.loads(text)
        except Exception as exc:  # pragma: no cover - best effort parsing
            raise RuntimeError('Failed to parse Gemini response') from exc
