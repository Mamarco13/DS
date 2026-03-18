import json
from llm import BasicLLM, TranslationDecorator, SentimentDecorator

def main():
    # Leemos la configuración
    with open("config.json", "r", encoding="utf-8") as f:
        config = json.load(f)

    text = config["texto"]
    model_llm = config["model_llm"]
    model_translation = config["model_translation"]
    model_sentiment = config["model_sentiment"]
    token = config["huggingface_api_token"]

    # 1. LLM básico
    basic_llm = BasicLLM(model_llm, token)
    basic_result = basic_llm.generate_summary(text)

    # 2. Traducción
    translation_llm = TranslationDecorator(basic_llm, model_translation, token)
    translation_result = translation_llm.generate_summary(text)

    # 3. Sentimiento
    sentiment_llm = SentimentDecorator(basic_llm, model_sentiment, token) 
    sentiment_result = sentiment_llm.generate_summary(text)

    # 4. Combinación (traducción + sentimiento)
    # Orden: primero resumimos, luego analizamos y por último traducimos

    combined_llm = TranslationDecorator(
        SentimentDecorator(
            basic_llm,
            model_sentiment,
            token
        ),
        model_translation,
        token
    )
    combined_result = combined_llm.generate_summary(text)

    # Mostrar resultados
    print("\n--- ORIGINAL ---")
    print(text)

    print("\n--- BASIC ---")
    print(basic_result)

    print("\n--- TRANSLATION ---")
    print(translation_result)

    print("\n--- SENTIMENT ---")
    print(sentiment_result)

    print("\n--- COMBINED ---")
    print(combined_result)


if __name__ == "__main__":
    main()

