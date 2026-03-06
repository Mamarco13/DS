from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from EstrategiaScrap import EstrategiaScrap

class ScrapSelenium(EstrategiaScrap):
    def __init__(self, PaginaWeb):
        super().__init__(PaginaWeb)

    def scrap(self, pages):
        options = Options()
        options.add_argument("--headless=new")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")

        driver = webdriver.Chrome(options=options)

        try:
            for page in range(1, pages + 1):
                url = f"{self.PaginaWeb}?page_num={page}"
                driver.get(url)
                print(f"Scrapeando en {url}")
        finally:
            driver.quit()