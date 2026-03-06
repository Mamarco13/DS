import ScrapBS
import ScrapSelenium

if __name__ == "__main__":
    paginaWeb = "https://www.scrapethissite.com/pages/forms/"
    print("========================PRÁCTICA 1 - EJERCICIO 3========================\n")
    print("¿De qué manera quieres scrapear la página?")
    print("1. Usando BeautifulSoup")
    print("2. Usando Selenium")
    print("3. Ambos métodos")
    opcion = input("Ingresa el número de tu opción: ")
    if opcion == "1":
        print("Scrapeando con BeautifulSoup...")
        scrapBS = ScrapBS.ScrapBS(paginaWeb)
        scrapBS.scrap(5)
    elif opcion == "2":
        print("Scrapeando con Selenium...")
        scrapSelenium = ScrapSelenium.ScrapSelenium(paginaWeb)
        scrapSelenium.scrap(5)
    elif opcion == "3":
        print("Scrapeando con BeautifulSoup...")
        scrapBS = ScrapBS.ScrapBS(paginaWeb)
        scrapBS.scrap(5)
        print("\nScrapeando con Selenium...")
        scrapSelenium = ScrapSelenium.ScrapSelenium(paginaWeb)
        scrapSelenium.scrap(5)
    else:
        print("Opción no válida. Por favor, ingresa 1, 2 o 3.")