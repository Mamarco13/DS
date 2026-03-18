from abc import ABC, abstractmethod

class LLM(ABC):
    @abstractmethod
    def generate_summary(self, text: str) -> str:
        pass