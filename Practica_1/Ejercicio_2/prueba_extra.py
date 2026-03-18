

import requests
import base64

API_URL = "https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0"

headers = {
    "Authorization": "Bearer TU_TOKEN"
}

payload = {
    "inputs": "A futuristic city at sunset, ultra realistic, 4k"
}

response = requests.post(API_URL, headers=headers, json=payload)

print("Status:", response.status_code)
print("Content-Type:", response.headers.get("content-type"))

if "image" in response.headers.get("content-type", ""):
    with open("imagen.png", "wb") as f:
        f.write(response.content)
    print("✅ Imagen guardada como imagen.png")
else:
    print("❌ Error:")
    print(response.text)