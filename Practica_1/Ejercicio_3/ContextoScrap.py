class ContextoScrap:

    def __init__(self, estrategia):
        self.estrategia = estrategia

    def setEstrategia(self, estrategia):
        self.estrategia = estrategia

    def ejecutarScrap(self, pages):
        self.estrategia.scrap(pages)