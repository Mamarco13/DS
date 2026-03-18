from .decorator import LLMDecorator

class SentimentDecorator(LLMDecorator):
    def __init__(self, llm, model_sentiment: str, api_token: str):
        super().__init__(llm)
        self.model_sentiment = model_sentiment
        self.api_token = api_token

    def generate_summary(self, text: str) -> str:
        summary = self.llm.generate_summary(text)

        #Aquí llamaríamos a la API de análisis de sentimiento
        sentiment = "Positivo"  # Resultado simulado

        return f"{summary}\nSentimiento: {sentiment}"
    