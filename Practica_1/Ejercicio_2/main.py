import json
from llm import BasicLLM, TranslationDecorator, SentimentDecorator, ImageDecorator

# IMPRESIÓN DE RESULTADOS

# Métodos auxiliares para indicar el progreso
def print_step(message):
    print(f"\n[*] {message}...")

def print_done(message="Completado"):
    print(f"[OK] {message}")

# Muestra el título centrado y el contenido debajo, separado por líneas
def print_section(title, content):
    print("\n" + "=" * 60)
    print(f"{title.center(60)}")
    print("=" * 60)
    print(content)

# Función principal
def main():

    # Leemos la configuación
    with open("config.json", "r", encoding="utf-8") as f:
        config = json.load(f)

    text = config["texto"]
    model_llm = config["model_llm"]
    model_translation = config["model_translation"]
    model_sentiment = config["model_sentiment"]
    model_image = config["model_image"]
    output_file = config["output_file"]
    token = config["huggingface_api_token"]

    basic_llm = BasicLLM(model_llm, token)

    # 🔹 Texto original

    print_section("ORIGINAL TEXT", text)

    # 🔹 Resumen
    print_step("Generando resumen")
    basic_result = basic_llm.generate_summary(text)
    print_done("Resumen generado")

    print_section("BASIC SUMMARY", basic_result)

    # 🔹 Traducción
    print_step("Traduciendo texto")
    translation_llm = TranslationDecorator(basic_llm, model_translation)
    translation_result = translation_llm.generate_summary(text)
    print_done("Traducción completada")

    print_section("TRANSLATION", translation_result)

    # 🔹 Sentimiento
    print_step("Analizando sentimiento")
    sentiment_llm = SentimentDecorator(basic_llm, model_sentiment)
    sentiment_result = sentiment_llm.generate_summary(text)
    print_done("Análisis completado")

    print_section("SENTIMENT", sentiment_result)

    # 🔹 Combinado
    print_step("Ejecutando combinación (resumen + traducción + sentimiento)")
    combined_llm = SentimentDecorator(
        TranslationDecorator(
            basic_llm,
            model_translation,
        ),
        model_sentiment,
    )
    combined_result = combined_llm.generate_summary(text)
    print_done("Combinación completada")

    print_section("COMBINED", combined_result)

    # 🔹 Imagen
    print_step("Convirtiendo texto a imagen")
    image_llm = ImageDecorator(basic_llm, model_image, output_file)
    image_result = image_llm.generate_summary(text)
    print_done("Imagen creada")

    print_section("IMAGE", image_result)


if __name__ == "__main__":
    main()

