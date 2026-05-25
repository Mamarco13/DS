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

---

# Practica 4.2 — Sistema de traducción de lenguaje por audio

Aplicación Flutter + API Rails con PostgreSQL para crear lenguajes personalizados
basados en sonidos y traducirlos mediante comparación de espectrogramas.

---

## Componentes

| Carpeta          | Tecnología                 | Función                                               |
|------------------|----------------------------|-------------------------------------------------------|
| `salvacion_app/` | Flutter (Dart)             | App móvil/desktop: grabar, guardar y traducir sonidos |
| `salvacion_bd/`  | Ruby on Rails + PostgreSQL | API REST con CRUD de lenguajes y palabras             |

---

## Archivos creados

### Flutter (salvacion_app/)

| Ruta                                          | Descripción                                                  |
|-----------------------------------------------|--------------------------------------------------------------|
| `lib/main.dart`                               | Punto de entrada, lanza LenguajesScreen                      |
| `lib/screens/lenguajes_screen.dart`           | Pantalla principal: lista, crea y elimina lenguajes          |
| `lib/screens/enviar_sonido.dart`              | Pantalla para grabar audio y guardar una palabra en la BD    |
| `lib/screens/comparador_audio_screen.dart`    | Pantalla de comparación directa entre dos audios grabados    |
| `lib/src/api/rails_service.dart`              | Servicio HTTP que conecta Flutter con la API Rails           |
| `lib/src/api/espectrograma.dart`              | Clase Espectrograma: normalización, MFCC, similitud coseno   |
| `lib/src/api/fft.dart`                        | Construcción del espectrograma mediante STFT                 |
| `lib/src/api/conversor_audio.dart`            | Lectura de archivos WAV y conversión a muestras PCM          |
| `lib/src/api/comparador.dart`                 | Patrón Strategy: ComparadorCoseno y ComparadorMFCC           |

### Rails (salvacion_bd/)

| Ruta                                          | Descripción                                                  |
|-----------------------------------------------|--------------------------------------------------------------|
| `app/models/lenguaje.rb`                      | Modelo Lenguaje (has_many palabras)                          |
| `app/models/palabra.rb`                       | Modelo Palabra (texto, tipo, duracion, espectrograma JSONB)  |
| `app/controllers/lenguajes_controller.rb`     | CRUD de lenguajes + endpoint buscar                          |
| `app/controllers/palabras_controller.rb`      | CRUD de palabras dentro de un lenguaje                       |
| `app/services/comparador_espectrograma.rb`    | Similitud coseno entre espectrogramas (mismo algoritmo Dart) |
| `config/routes.rb`                            | Rutas REST anidadas lenguajes/palabras                       |
| `db/migrate/`                                 | Migraciones: tabla lenguajes y tabla palabras                |

---

## Arquitectura del sistema

```
Cliente (Flutter)
    │
    ├──► Audio Parser (espectrograma.dart + fft.dart)
    │         Convierte WAV en espectrograma (STFT + ventana Hanning)
    │
    ├──► Rails API (salvacion_bd)
    │         Guarda/busca palabras por espectrograma (similitud coseno)
    │
    └──► Intérprete (Flutter)
              Aplica reglas gramaticales y llama a un LLM
```

---

## Puesta en marcha

### 1. API Rails (salvacion_bd)

**Requisitos:** Ruby 4+, Rails 8+, PostgreSQL 14+

```bash
cd salvacion_bd
bundle install
rails db:create db:migrate
rails server
```

La API corre en `http://localhost:3000`.

### 2. App Flutter (salvacion_app)

**Requisitos:** Flutter 3.44+, Dart 3.11+

```bash
cd salvacion_app
flutter pub get
flutter run -d linux   # o -d android / -d ios
```

> En Linux desktop la URL de Rails es `localhost:3000`.
> En emulador Android usar `10.0.2.2:3000` en `rails_service.dart`.

---

## Endpoints Rails

### Lenguajes
| Método | Ruta              | Descripción               |
|--------|-------------------|---------------------------|
| GET    | `/lenguajes`      | Listar todos              |
| POST   | `/lenguajes`      | Crear lenguaje            |
| GET    | `/lenguajes/:id`  | Ver uno                   |
| PATCH  | `/lenguajes/:id`  | Editar nombre             |
| DELETE | `/lenguajes/:id`  | Eliminar (y sus palabras) |

### Palabras
| Método | Ruta                      | Descripción              |
|--------|---------------------------|--------------------------|
| GET    | `/lenguajes/:id/palabras` | Listar palabras          |
| POST   | `/lenguajes/:id/palabras` | Añadir palabra           |
| PATCH  | `/palabras/:id`           | Editar palabra           |
| DELETE | `/palabras/:id`           | Eliminar palabra         |
| POST   | `/lenguajes/:id/buscar`   | Buscar por espectrograma |

### Ejemplo — Crear palabra
```bash
curl -X POST http://localhost:3000/lenguajes/1/palabras \
  -H "Content-Type: application/json" \
  -d '{
    "palabra": {
      "texto": "gustar",
      "tipo": "verbo",
      "duracion": 0.5,
      "espectrograma": {"frames": [[0.1, 0.2, 0.3]]}
    }
  }'
```

### Ejemplo — Buscar palabra por espectrograma
```bash
curl -X POST http://localhost:3000/lenguajes/1/buscar \
  -H "Content-Type: application/json" \
  -d '{"espectrograma": {"frames": [[0.1, 0.2, 0.3]]}}'
```

Respuesta:
```json
{ "palabra": "gustar", "tipo": "verbo", "duracion": 2.0 }
```

---

## Flujo de uso en la app

1. Abre la app → pantalla **Mis lenguajes**
2. Pulsa **+** para crear un lenguaje nuevo
3. Toca el lenguaje → pantalla **Añadir palabra**
4. Escribe el significado, selecciona el tipo y graba el audio
5. Pulsa **Guardar palabra** — se envía a Rails y queda en la BD

---

## Tipos de palabra válidos

`verbo` · `sustantivo` · `adjetivo` · `pronombre` · `otro`

---

## Algoritmo de comparación

La similitud entre espectrogramas se calcula mediante **similitud coseno**
sobre el perfil espectral promedio de los frames, con:
- Umbral de aceptación: **0.6**
- Ventana STFT: **Hanning** (chunk 1024, overlap 0.5)
- Frecuencia de muestreo: **44100 Hz**
