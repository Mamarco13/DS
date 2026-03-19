from .decorator import LLMDecorator

class TranslationDecorator(LLMDecorator):
    def __init__(self, llm, model_translation: str):
        super().__init__(llm)
        self.model_translation = model_translation

    def generate_summary(self, text: str) -> str:
        summary = self.llm.generate_summary(text)

        response = self.query(
            self.model_translation,
            {"inputs": summary}
        )

        try:
            return response[0]["translation_text"]
        except Exception:
            return f"[ERROR en traducción]: {response}"