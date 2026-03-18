from abc import ABC, abstractmethod

class LLM(ABC):
    def __init__(self, api_token: str):
        self.api_token = api_token

    @abstractmethod
    def generate_summary(self, text: str) -> str:
        pass