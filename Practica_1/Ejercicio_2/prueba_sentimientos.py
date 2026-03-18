import requests

API_URL = "https://router.huggingface.co/hf-inference/models/nlptown/bert-base-multilingual-uncased-sentiment"
headers = {
    "Authorization": "Bearer TU_TOKEN"
}

def query(payload):
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()

response = query({
    "inputs": "Hugging Face is creating a tool that democratizes AI. It is a platform that allows developers to easily access and use state-of-the-art machine learning models. The company is focused on making AI more accessible and user-friendly, with the goal of enabling more people to benefit from the power of artificial intelligence."
})

try:
    # response es [[{...}, {...}, ...]]
    scores = response[0]

    # coger el mejor
    best = max(scores, key=lambda x: x["score"])

    label = best["label"]
    score = best["score"]

    print(f"Sentiment: {label}")

except Exception as e:
    print("Error procesando la respuesta:")
    print(response)