from servicioAmericano import ServicioAmericano
from servicioEuropeo import ServicioEuropeo

if __name__ == "__main__":

    input_temp = input("Ingrese la temperatura en Fahrenheit (o deje en blanco para obtener la temperatura actual): ")
    if input_temp.strip() == "":
        servicio_americano = ServicioAmericano(None)
    else:
        try:
            temp_f = float(input_temp)
            servicio_americano = ServicioAmericano(temp_f)
        except ValueError:
            print("Entrada no válida. Se usará la temperatura actual.")
            servicio_americano = ServicioAmericano(None)
    
    servicio_europeo = ServicioEuropeo(servicio_americano)
    
    print(f"Temperatura en Fahrenheit: {servicio_americano.getTemperatura()}°F")
    print(f"Temperatura en Celsius: {servicio_europeo.getTemperatura()}°C")