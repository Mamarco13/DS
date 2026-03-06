import ScrapBS
import ScrapSelenium
from ContextoScrap import ContextoScrap


if __name__ == "__main__":

    paginaWeb = "https://www.scrapethissite.com/pages/forms/"

    print("========================PRÁCTICA 1 - EJERCICIO 3========================\n")

    print("¿De qué manera quieres scrapear la página?")
    print("1. Usando BeautifulSoup")
    print("2. Usando Selenium")
    print("3. Ambos métodos")

    opcion = input("Ingresa el número de tu opción: ")

    contexto = ContextoScrap(None)

    if opcion == "1":

        print("Scrapeando con BeautifulSoup...")
        estrategia = ScrapBS.ScrapBS(paginaWeb)
        contexto.setEstrategia(estrategia)
        contexto.ejecutarScrap(5)

    elif opcion == "2":

        print("Scrapeando con Selenium...")
        estrategia = ScrapSelenium.ScrapSelenium(paginaWeb)
        contexto.setEstrategia(estrategia)
        contexto.ejecutarScrap(5)

    elif opcion == "3":

        print("Scrapeando con BeautifulSoup...")
        estrategia = ScrapBS.ScrapBS(paginaWeb)
        contexto.setEstrategia(estrategia)
        contexto.ejecutarScrap(5)

        print("\nScrapeando con Selenium...")
        estrategia = ScrapSelenium.ScrapSelenium(paginaWeb)
        contexto.setEstrategia(estrategia)
        contexto.ejecutarScrap(5)

    else:
        print("Opción no válida.")