from .decorator import LLMDecorator


class ImageDecorator(LLMDecorator):
    def __init__(self, llm, model_image: str, output_file="imagen.png"):
        super().__init__(llm)
        self.model_image = model_image
        self.output_file = output_file

    def generate_summary(self, text: str) -> str:
        prompt = self.llm.generate_summary(text)

        response = self.query(
            self.model_image,
            {"inputs": prompt}
        )

        # comprobar si es imagen
        if hasattr(response, "content"):
            with open(self.output_file, "wb") as f:
                f.write(response.content)

            return f"Imagen generada: {self.output_file}"

        else:
            return f"[ERROR generando imagen]: {response}"