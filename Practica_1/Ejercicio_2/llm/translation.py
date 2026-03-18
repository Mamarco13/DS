from .decorator import LLMDecorator

class TranslationDecorator(LLMDecorator):
    def __init__(self, llm, model_translation: str, api_token: str):
        super().__init__(llm)
        self.model_translation = model_translation
        self.api_token = api_token

    def generate_summary(self, text: str) -> str:
        summary = self.llm.generate_summary(text)

        # Aquí llamaríamos a la API de traducción
        translation = "Traducción al inglés"  # Resultado simulado

        return f"{summary}\nTraducción: {translation}"