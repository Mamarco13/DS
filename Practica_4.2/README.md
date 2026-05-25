Servicio basico para comparar espectrogramas de audio (WAV)

Requisitos
- Python 3.10+ (recomendado)

Instalacion
- pip install -r requirements.txt

Ejecutar
- python app.py

Endpoints
- GET /health
- POST /compare (multipart/form-data)
  - audio1: archivo wav
  - audio2: archivo wav
  - threshold: opcional (float, por defecto 0.9)

Ejemplo con curl
- curl -X POST http://localhost:8000/compare -F "audio1=@a.wav" -F "audio2=@b.wav" -F "threshold=0.9"

Notas
- Solo se soportan archivos WAV.
- Si las tasas de muestreo difieren, el segundo audio se re-muestrea.
