from abc import ABC, abstractmethod

class LLM(ABC):
    def __init__(self, api_token: str):
        self.api_token = api_token

    def query(self, model: str, payload: dict):
        api_url = f"https://router.huggingface.co/hf-inference/models/{model}"

        headers = {
            "Authorization": f"Bearer {self.api_token}"
        }

        response = requests.post(api_url, headers=headers, json=payload)
        return response.json()

    @abstractmethod
    def generate_summary(self, text: str) -> str:
        pass