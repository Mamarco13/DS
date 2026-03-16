from flask import Flask, render_template, request, redirect, url_for

from servicioAmericano import ServicioAmericano
from servicioEuropeo import ServicioEuropeo

app = Flask(__name__)


# -----------------------------
# Estado del sistema domótico
# -----------------------------

exteriorReal = ServicioAmericano(None)  # Fetches data from API
T_exterior = exteriorReal.getTemperatura()

temperaturas_f = {
    "salon": 73.4,
    "cocina": 75.2,
    "dormitorio": 69.8,
    "bano": 77.0,
    "despacho": 71.6,
    "exterior": T_exterior
}

limite_min = 15
limite_max = 30


# -----------------------------
# Conversión usando Adapter
# -----------------------------

def obtener_celsius(temp_f):

    servicio_americano = ServicioAmericano(temp_f)
    servicio_europeo = ServicioEuropeo(servicio_americano)

    return servicio_europeo.getTemperatura()


# -----------------------------
# Calcular estado de la casa
# -----------------------------

def calcular_estado(temp_c):

    global limite_min, limite_max

    if temp_c > limite_max:
        return "⚠️ Temperatura demasiado alta"

    if temp_c < limite_min:
        return "❄️ Temperatura demasiado baja"

    return "Todo en orden"


# -----------------------------
# Dashboard principal
# -----------------------------

@app.route("/")
def inicio():

    temperaturas_c = {}

    for habitacion, temp_f in temperaturas_f.items():
        temperaturas_c[habitacion] = obtener_celsius(temp_f)

    temperatura_media = sum(temperaturas_c.values()) / len(temperaturas_c)

    estado_casa = calcular_estado(temperatura_media)

    return render_template(
        "index.html",

        estado_casa=estado_casa,

        temperatura_principal_c=round(temperatura_media, 1),

        exterior_c=round(temperaturas_c["exterior"], 1),
        exterior_f=temperaturas_f["exterior"],

        salon_c=round(temperaturas_c["salon"], 1),
        salon_f=temperaturas_f["salon"],

        cocina_c=round(temperaturas_c["cocina"], 1),
        cocina_f=temperaturas_f["cocina"],

        dormitorio_c=round(temperaturas_c["dormitorio"], 1),
        dormitorio_f=temperaturas_f["dormitorio"],

        bano_c=round(temperaturas_c["bano"], 1),
        bano_f=temperaturas_f["bano"],

        despacho_c=round(temperaturas_c["despacho"], 1),
        despacho_f=temperaturas_f["despacho"]
    )


# -----------------------------
# Página de límites
# -----------------------------

@app.route("/limites", methods=["GET", "POST"])
def limites():

    global limite_min, limite_max

    if request.method == "POST":

        limite_min = float(request.form.get("min_temp"))
        limite_max = float(request.form.get("max_temp"))

        return redirect(url_for("inicio"))

    return render_template(
        "limites.html",
        min_temp=limite_min,
        max_temp=limite_max
    )


# -----------------------------
# Zeus - Control manual
# -----------------------------

@app.route("/zeus", methods=["GET", "POST"])
def zeus():

    if request.method == "POST":

        for habitacion in temperaturas_f:

            nuevo_valor = request.form.get(habitacion)

            if nuevo_valor:
                temperaturas_f[habitacion] = float(nuevo_valor)

        return redirect(url_for("inicio"))

    return render_template(
        "zeus.html",
        temperaturas=temperaturas_f
    )


# -----------------------------
# Ejecutar servidor
# -----------------------------

if __name__ == "__main__":
    app.run(debug=True)