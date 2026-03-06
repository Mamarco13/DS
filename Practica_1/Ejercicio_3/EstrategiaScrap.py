class EstrategiaScrap:
    def __init__(self, PaginaWeb):
        self.PaginaWeb = PaginaWeb.rstrip("/") + "/"
    def scrap(self, pages):
        raise NotImplementedError("El método lo implementa cada subclase")