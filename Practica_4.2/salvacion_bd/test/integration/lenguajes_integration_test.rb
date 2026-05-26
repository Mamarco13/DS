require "test_helper"

# =============================================================================
# TESTS DE INTEGRACIÓN – LenguajesController
# =============================================================================
#
# Usan ActionDispatch::Integration::Session para hacer peticiones HTTP reales
# contra el stack Rails completo (rutas → controlador → modelo → BD de test).
#
# La BD de test se reinicia automáticamente entre tests gracias a los fixtures.
# Ejecución:
#   bin/rails test test/integration/lenguajes_integration_test.rb
# =============================================================================

class LenguajesIntegrationTest < ActionDispatch::IntegrationTest

  # ---------------------------------------------------------------------------
  # Helper: JSON mínimo de espectrograma con energía > 0.00001
  # ---------------------------------------------------------------------------
  ESPECTROGRAMA_MINIMO = {
    "frames" => [
      [0.5, 0.6, 0.7, 0.8, 0.9, 0.8, 0.7, 0.6],
      [0.6, 0.7, 0.8, 0.9, 0.8, 0.7, 0.6, 0.5],
      [0.7, 0.8, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4],
      [0.8, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3]
    ],
    "perfil"     => [0.5, 0.6, 0.7, 0.8, 0.7, 0.6, 0.5],
    "mfcc"       => Array.new(13) { [0.1, -0.1, 0.2, -0.2] },
    "chunkSize"  => 1024,
    "sampleRate" => 44100,
    "windowType" => "hanning",
    "overlap"    => 0.5,
    "duracion"   => 0.046
  }.freeze

  HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze

  # ===========================================================================
  # GET /lenguajes
  # ===========================================================================

  test "GET /lenguajes devuelve status 200 y un array JSON" do
    get "/lenguajes", headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_kind_of Array, body
  end

  test "GET /lenguajes incluye los lenguajes cargados por los fixtures" do
    get "/lenguajes", headers: HEADERS

    body = JSON.parse(response.body)
    nombres = body.map { |l| l["nombre"] }
    assert_includes nombres, "Klingon"
    assert_includes nombres, "Elvish"
  end

  test "GET /lenguajes devuelve objetos con las claves id y nombre" do
    get "/lenguajes", headers: HEADERS

    body = JSON.parse(response.body)
    assert body.all? { |l| l.key?("id") && l.key?("nombre") },
           "Cada lenguaje debe tener las claves 'id' y 'nombre'"
  end

  # ===========================================================================
  # POST /lenguajes
  # ===========================================================================

  test "POST /lenguajes crea un nuevo lenguaje y devuelve 201" do
    assert_difference "Lenguaje.count", 1 do
      post "/lenguajes",
           params:  { lenguaje: { nombre: "Dothraki" } }.to_json,
           headers: HEADERS
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Dothraki", body["nombre"]
    assert body["id"].present?, "La respuesta debe incluir el id asignado"
  end

  test "POST /lenguajes persiste el lenguaje en la BD" do
    post "/lenguajes",
         params:  { lenguaje: { nombre: "Na'vi" } }.to_json,
         headers: HEADERS

    assert Lenguaje.exists?(nombre: "Na'vi"),
           "El lenguaje debe existir en la BD tras el POST"
  end

  test "POST /lenguajes con nombre duplicado devuelve 422" do
    # 'Klingon' ya existe en los fixtures
    assert_no_difference "Lenguaje.count" do
      post "/lenguajes",
           params:  { lenguaje: { nombre: "Klingon" } }.to_json,
           headers: HEADERS
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].any? { |e| e.match?(/nombre/i) },
           "Los errores deben mencionar el campo 'nombre'"
  end

  test "POST /lenguajes sin nombre devuelve 422 con errores" do
    assert_no_difference "Lenguaje.count" do
      post "/lenguajes",
           params:  { lenguaje: { nombre: "" } }.to_json,
           headers: HEADERS
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body.key?("errors"), "La respuesta debe incluir la clave 'errors'"
  end

  # ===========================================================================
  # GET /lenguajes/:id
  # ===========================================================================

  test "GET /lenguajes/:id devuelve el lenguaje correcto con status 200" do
    lenguaje = lenguajes(:klingon)

    get "/lenguajes/#{lenguaje.id}", headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal lenguaje.id,     body["id"]
    assert_equal lenguaje.nombre, body["nombre"]
  end

  test "GET /lenguajes/:id con id inexistente devuelve 404" do
    get "/lenguajes/999999999", headers: HEADERS

    assert_response :not_found
  end

  # ===========================================================================
  # DELETE /lenguajes/:id
  # ===========================================================================

  test "DELETE /lenguajes/:id elimina el lenguaje y devuelve 204" do
    lenguaje = lenguajes(:klingon)

    assert_difference "Lenguaje.count", -1 do
      delete "/lenguajes/#{lenguaje.id}", headers: HEADERS
    end

    assert_response :no_content
    assert_not Lenguaje.exists?(lenguaje.id),
               "El lenguaje no debe existir tras el DELETE"
  end

  test "DELETE /lenguajes/:id elimina también sus palabras (cascade)" do
    lenguaje = lenguajes(:klingon)
    ids_palabras = lenguaje.palabras.pluck(:id)

    delete "/lenguajes/#{lenguaje.id}", headers: HEADERS

    assert_response :no_content
    ids_palabras.each do |pid|
      assert_not Palabra.exists?(pid),
                 "La palabra #{pid} debería haberse eliminado en cascada"
    end
  end

  # ===========================================================================
  # GET /lenguajes/:id/palabras
  # ===========================================================================

  test "GET /lenguajes/:id/palabras devuelve la lista de palabras con status 200" do
    lenguaje = lenguajes(:klingon)

    get "/lenguajes/#{lenguaje.id}/palabras", headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_kind_of Array, body
  end

  test "GET /lenguajes/:id/palabras incluye las palabras del fixture" do
    lenguaje = lenguajes(:klingon)

    get "/lenguajes/#{lenguaje.id}/palabras", headers: HEADERS

    body = JSON.parse(response.body)
    textos = body.map { |p| p["texto"] }
    assert_includes textos, "hola"
  end

  test "GET /lenguajes/:id/palabras devuelve lista vacía si no hay palabras" do
    # Crear lenguaje nuevo sin palabras
    lenguaje = Lenguaje.create!(nombre: "Vacío_#{SecureRandom.hex(4)}")

    get "/lenguajes/#{lenguaje.id}/palabras", headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_empty body

    lenguaje.destroy
  end

  # ===========================================================================
  # POST /lenguajes/:id/palabras
  # ===========================================================================

  test "POST /lenguajes/:id/palabras crea una palabra y devuelve 201" do
    lenguaje = lenguajes(:klingon)

    assert_difference "Palabra.count", 1 do
      post "/lenguajes/#{lenguaje.id}/palabras",
           params: {
             palabra: {
               texto:        "guerra",
               tipo:         "sustantivo",
               duracion:     1.0,
               espectrograma: ESPECTROGRAMA_MINIMO
             }
           }.to_json,
           headers: HEADERS
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "guerra",     body["texto"]
    assert_equal "sustantivo", body["tipo"]
  end

  test "POST /lenguajes/:id/palabras con tipo inválido devuelve 422" do
    lenguaje = lenguajes(:klingon)

    assert_no_difference "Palabra.count" do
      post "/lenguajes/#{lenguaje.id}/palabras",
           params: {
             palabra: {
               texto:        "inválido",
               tipo:         "tipo_que_no_existe",
               espectrograma: ESPECTROGRAMA_MINIMO
             }
           }.to_json,
           headers: HEADERS
    end

    assert_response :unprocessable_entity
  end

  test "POST /lenguajes/:id/palabras sin texto devuelve 422" do
    lenguaje = lenguajes(:klingon)

    assert_no_difference "Palabra.count" do
      post "/lenguajes/#{lenguaje.id}/palabras",
           params: {
             palabra: {
               texto:        "",
               tipo:         "verbo",
               espectrograma: ESPECTROGRAMA_MINIMO
             }
           }.to_json,
           headers: HEADERS
    end

    assert_response :unprocessable_entity
  end

  # ===========================================================================
  # POST /lenguajes/:id/buscar
  # ===========================================================================

  test "POST /lenguajes/:id/buscar con lenguaje sin palabras devuelve 'unknown'" do
    lenguaje = Lenguaje.create!(nombre: "Vacío_buscar_#{SecureRandom.hex(4)}")

    post "/lenguajes/#{lenguaje.id}/buscar",
         params: {
           espectrograma: ESPECTROGRAMA_MINIMO,
           estrategia:    "coseno"
         }.to_json,
         headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "unknown", body["palabra"]

    lenguaje.destroy
  end

  test "POST /lenguajes/:id/buscar con palabras devuelve un resultado JSON válido" do
    lenguaje = lenguajes(:klingon)

    post "/lenguajes/#{lenguaje.id}/buscar",
         params: {
           espectrograma: ESPECTROGRAMA_MINIMO,
           estrategia:    "coseno"
         }.to_json,
         headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.key?("palabra"),  "Debe incluir la clave 'palabra'"
    assert body.key?("tipo"),     "Debe incluir la clave 'tipo'"
    assert body.key?("duracion"), "Debe incluir la clave 'duracion'"
  end

  test "POST /lenguajes/:id/buscar con el mismo espectrograma devuelve la palabra guardada" do
    # Fixture hola_klingon usa ESPECTROGRAMA_MINIMO (mismo patron)
    lenguaje = lenguajes(:klingon)

    post "/lenguajes/#{lenguaje.id}/buscar",
         params: {
           espectrograma: ESPECTROGRAMA_MINIMO,
           estrategia:    "coseno"
         }.to_json,
         headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    # La similitud con el espectrograma de "hola" debe superar el umbral
    assert_equal "hola", body["palabra"],
                 "Debe encontrar 'hola' al buscar con el mismo espectrograma"
  end

  test "POST /lenguajes/:id/buscar sin espectrograma devuelve 400" do
    lenguaje = lenguajes(:klingon)

    post "/lenguajes/#{lenguaje.id}/buscar",
         params:  { estrategia: "coseno" }.to_json,
         headers: HEADERS

    assert_response :bad_request
  end

  test "POST /lenguajes/:id/buscar con estrategia mcff devuelve resultado válido" do
    lenguaje = lenguajes(:klingon)

    post "/lenguajes/#{lenguaje.id}/buscar",
         params: {
           espectrograma: ESPECTROGRAMA_MINIMO,
           estrategia:    "mcff"
         }.to_json,
         headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.key?("palabra"), "Debe incluir la clave 'palabra' con estrategia mcff"
  end
end
