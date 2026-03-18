from .base import LLM

class BasicLLM(LLM):
    def __init__(self, model_llm: str, api_token: str):
        super().__init__(api_token)
        self.model_llm = model_llm

    def generate_summary(self, text: str) -> str:
        # Aquí llamaríamos a la API
        return "Resumen generado por BasicLLM"