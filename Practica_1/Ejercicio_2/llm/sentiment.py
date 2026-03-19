from .decorator import LLMDecorator

class SentimentDecorator(LLMDecorator):
    def __init__(self, llm, model_sentiment: str):
        super().__init__(llm)
        self.model_sentiment = model_sentiment

    def generate_summary(self, text: str) -> str:
        summary = self.llm.generate_summary(text)

        response = self.query(
            self.model_sentiment,
            {"inputs": summary}
        )

        try:
            scores = response[0]
            best = max(scores, key=lambda x: x["score"])
            label = best["label"]
        except Exception:
            label = f"ERROR: {response}"

        return label