from .decorator import LLMDecorator

class TranslationDecorator(LLMDecorator):
    def __init__(self, llm, model_translation: str):
        super().__init__(llm)
        self.model_translation = model_translation

    def generate_summary(self, text: str) -> str:
        summary = self.llm.generate_summary(text)
        
        reponse = self.query(
            self.model_translation,
            {"inputs": summary}
        )

        try:
            return reponse[0]['translation_text']