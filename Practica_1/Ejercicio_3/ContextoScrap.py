import ScrapBS
import ScrapSelenium

if __name__ == "__main__":
    print("Este módulo define las clases para el contexto de scraping, incluyendo ScrapBS y ScrapSelenium.")
    scrapBS = ScrapBS.ScrapBS("https://www.scrapethissite.com/pages/forms/")
    #scrapBS.scrap(5)
    scrapSelenium = ScrapSelenium.ScrapSelenium("https://www.scrapethissite.com/pages/forms/")
    scrapSelenium.scrap(5)