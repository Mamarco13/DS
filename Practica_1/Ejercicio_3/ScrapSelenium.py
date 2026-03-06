from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from EstrategiaScrap import EstrategiaScrap
import csv
import os


class ScrapSelenium(EstrategiaScrap):
    def __init__(self, PaginaWeb):
        super().__init__(PaginaWeb)

    def scrap(self, pages):
        options = Options()
        options.add_argument("--headless=new")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")

        driver = webdriver.Chrome(options=options)

        try:
            os.makedirs("./csv", exist_ok=True)

            with open("./csv/ScrapSelenium.csv", "w", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([
                    "Equipo",
                    "Anio",
                    "Victorias",
                    "Derrotas",
                    "Derrotas en proroga",
                    "Porcentaje de victoria",
                    "Goles a favor",
                    "Goles en contra",
                    "Diferencia"
                ])

                for page in range(1, pages + 1):
                    url = f"{self.PaginaWeb}?page_num={page}"
                    driver.get(url)
                    print(f"Scrapeando en {url}")

                    WebDriverWait(driver, 10).until(
                        EC.presence_of_all_elements_located((By.CSS_SELECTOR, "tr.team"))
                    )

                    filas = driver.find_elements(By.CSS_SELECTOR, "tr.team")

                    for fila in filas:
                        equipo = fila.find_element(By.CSS_SELECTOR, "td.name").text.strip()
                        anio = fila.find_element(By.CSS_SELECTOR, "td.year").text.strip()
                        victorias = fila.find_element(By.CSS_SELECTOR, "td.wins").text.strip()
                        derrotas = fila.find_element(By.CSS_SELECTOR, "td.losses").text.strip()
                        derrotas_prorroga = fila.find_element(By.CSS_SELECTOR, "td.ot-losses").text.strip()
                        porcentaje_victoria = fila.find_element(By.CSS_SELECTOR, "td.pct").text.strip()
                        goles_favor = fila.find_element(By.CSS_SELECTOR, "td.gf").text.strip()
                        goles_contra = fila.find_element(By.CSS_SELECTOR, "td.ga").text.strip()
                        diferencia = fila.find_element(By.CSS_SELECTOR, "td.diff").text.strip()

                        writer.writerow([
                            equipo,
                            anio,
                            victorias,
                            derrotas,
                            derrotas_prorroga,
                            porcentaje_victoria,
                            goles_favor,
                            goles_contra,
                            diferencia
                        ])

            print("CSV generado en ./csv/ScrapSelenium.csv")

        finally:
            driver.quit()