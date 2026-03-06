import csv
import requests
from bs4 import BeautifulSoup
from EstrategiaScrap import EstrategiaScrap
from urllib.parse import urljoin

class ScrapBS(EstrategiaScrap):

    def __init__(self, PaginaWeb):
        super().__init__(PaginaWeb)

    def scrap(self, pages):
        # Asegura URL base correcta (sin dobles // raros)
        base_url = self.PaginaWeb.rstrip("/") + "/"

        with open("./csv/ScrapBS.csv", "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["Equipo", "Anio", "Victorias", "Derrotas", "Derrotas en prórrroga", "% de victoria", "Goles a favor", "Goles en contra", "+-"])

            for page in range(1, pages + 1):
                scrapearEn = base_url + "?page_num=" + str(page)

                response = requests.get(scrapearEn, timeout=20)
                response.raise_for_status()

                soup = BeautifulSoup(response.text, "html.parser")
                rows = soup.select("table.table tr.team")

                print(f"Scrapeando página {page}")

                for row in rows:
                    tds = row.select("td")
                    if len(tds) != 9:
                        continue

                    cols = [td.get_text(strip=True) for td in tds]
                    cols = [c if c != "" else "0" for c in cols]

                    cols[1] = int(cols[1])
                    cols[2] = int(cols[2])
                    cols[3] = int(cols[3])
                    cols[4] = int(cols[4])
                    cols[5] = float(cols[5])
                    cols[6] = int(cols[6])
                    cols[7] = int(cols[7])
                    cols[8] = int(cols[8])

                    writer.writerow(cols)