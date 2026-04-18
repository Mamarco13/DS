# 🛡️ Chat Guardian – Práctica 2

Aplicación en **Flutter** que implementa un chat con IA (Gemini) donde el usuario intenta descubrir una **palabra secreta** protegida por un guardián.

Se utiliza el patrón **Decorator** para modificar dinámicamente el comportamiento del sistema según el nivel de dificultad.

---

## 🧠 Arquitectura

- **SecretKeeper**: interfaz común
- **BasicSecretKeeper**: implementación base (gestiona Gemini)
- **SecretKeeperDecorator**: base del patrón
- **Decoradores**:
    - `StrongSystemPromptDecorator` → modifica el prompt
    - `KeywordBlockDecorator` → bloquea mensajes
    - `LengthLimitDecorator` → limita longitud

---

## 🎮 Niveles

| Nivel | Comportamiento |
|------|--------------|
| 1 | Básico |
| 2 | Strong + Length |
| 3 | Strong + Keyword + Length |

> El último decorador añadido es el primero en ejecutarse.

---

## 🔄 Flujo

1. Usuario envía mensaje
2. Decoradores interceptan/modifican
3. Se construye el prompt final
4. Gemini genera respuesta

---

## ⚙️ Ejecución

1. Crear un archivo `.env` con: API_KEY=TU_API_KEY
2. Ejecutar en terminal: flutter pub get

---

## ⚠️ Posibles problemas

- Revisar el modelo de Gemini en la documentación oficial:  
  https://ai.google.dev/gemini-api/docs?hl=es-419

- En el guion se indica usar:  
  `gemini-2.5-flash`

- En Windows, evitar rutas con tildes o espacios, ya que pueden causar errores al compilar.

---

## ⚙️ Configuración

- `FiltersConfig` → límites (longitud, faltas)
- `TypoUtils` → lista de errores comunes

---

## 💡 Diseño

- Uso de **Decorator** para evitar múltiples clases
- Separación entre UI, lógica y API
- Prompt construido de forma acumulativa

