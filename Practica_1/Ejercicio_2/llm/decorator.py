from .base import LLM

class LLMDecorator(LLM):
    def __init__(self, llm: LLM):
        self.llm = llm

    def generate_sumary(self, text: str) -> str:
        return self.llm.generate_summary(text)