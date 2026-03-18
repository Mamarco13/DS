
from urllib import response
import requests

class ServicioAmericano:
    def __init__(self, temperaturaF):
        if temperaturaF is None:
            # URL de la API
            url = "https://api.open-meteo.com/v1/forecast?latitude=37.1882&longitude=-3.6067&current=temperature_2m&temperature_unit=fahrenheit"
            # Realizar la petición GET
            response = requests.get(url)
            # Verificar si la petición fue exitosa (código 200)
            if response.status_code == 200:
                # Convertir la respuesta a formato JSON
                datos = response.json()
                # Extraer la temperatura actual
                self.temperaturaF = datos['current']['temperature_2m']
            else:
                print(f"Error: {response.status_code}")
        else:
            self.temperaturaF = temperaturaF
    
    def getTemperatura(self):
        return self.temperaturaF