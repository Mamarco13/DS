require "test_helper"

# =============================================================================
# TESTS DE INTEGRACIÓN – PalabrasController
# =============================================================================
#
# Testean los endpoints de palabras individuales (show, update, destroy)
# que están en /palabras/:id (fuera del scope anidado de lenguajes).
#
# Ejecución:
#   bin/rails test test/integration/palabras_integration_test.rb
# =============================================================================

class PalabrasIntegrationTest < ActionDispatch::IntegrationTest

  ESPECTROGRAMA_A = {
    "frames" => [
      [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2],
      [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1],
      [0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.05],
      [0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 0.02]
    ],
    "perfil"     => [0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1],
    "mfcc"       => Array.new(13) { [0.2, -0.2, 0.1, -0.1] },
    "chunkSize"  => 1024,
    "sampleRate" => 44100,
    "windowType" => "hanning",
    "overlap"    => 0.5,
    "duracion"   => 0.046
  }.freeze

  ESPECTROGRAMA_B = {
    "frames" => [
      [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.8],
      [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.8, 0.7],
      [0.5, 0.6, 0.7, 0.8, 0.9, 0.8, 0.7, 0.6]
    ],
    "perfil"     => [0.4, 0.5, 0.6, 0.7, 0.8, 0.7, 0.6],
    "mfcc"       => Array.new(13) { [-0.1, 0.2, -0.2, 0.1] },
    "chunkSize"  => 1024,
    "sampleRate" => 44100,
    "windowType" => "hanning",
    "overlap"    => 0.5,
    "duracion"   => 0.035
  }.freeze

  HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze

  # ===========================================================================
  # GET /palabras/:id
  # ===========================================================================

  test "GET /palabras/:id devuelve la palabra con status 200" do
    palabra = palabras(:hola_klingon)

    get "/palabras/#{palabra.id}", headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal palabra.id,    body["id"]
    assert_equal palabra.texto, body["texto"]
    assert_equal palabra.tipo,  body["tipo"]
  end

  test "GET /palabras/:id incluye todos los campos esperados" do
    palabra = palabras(:hola_klingon)

    get "/palabras/#{palabra.id}", headers: HEADERS

    body = JSON.parse(response.body)
    %w[id texto tipo duracion lenguaje_id].each do |campo|
      assert body.key?(campo), "La respuesta debe incluir el campo '#{campo}'"
    end
  end

  test "GET /palabras/:id con id inexistente devuelve 404" do
    get "/palabras/999999999", headers: HEADERS

    assert_response :not_found
  end

  # ===========================================================================
  # PUT /palabras/:id
  # ===========================================================================

  test "PUT /palabras/:id actualiza el texto y devuelve 200" do
    palabra = palabras(:hola_klingon)

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto: "adios",
            tipo:  "verbo"
          }
        }.to_json,
        headers: HEADERS

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "adios", body["texto"]

    # Verificar persistencia en BD
    assert_equal "adios", palabra.reload.texto
  end

  test "PUT /palabras/:id actualiza el tipo correctamente" do
    palabra = palabras(:hola_klingon)
    tipo_nuevo = "sustantivo"

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto: palabra.texto,
            tipo:  tipo_nuevo
          }
        }.to_json,
        headers: HEADERS

    assert_response :ok
    assert_equal tipo_nuevo, palabra.reload.tipo
  end

  test "PUT /palabras/:id actualiza la duración" do
    palabra = palabras(:hola_klingon)

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto:    palabra.texto,
            tipo:     palabra.tipo,
            duracion: 2.5
          }
        }.to_json,
        headers: HEADERS

    assert_response :ok
    assert_in_delta 2.5, palabra.reload.duracion, 0.001
  end

  test "PUT /palabras/:id actualiza el espectrograma cuando se envía" do
    palabra = palabras(:hola_klingon)

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto:        palabra.texto,
            tipo:         palabra.tipo,
            espectrograma: ESPECTROGRAMA_B
          }
        }.to_json,
        headers: HEADERS

    assert_response :ok
    # El espectrograma debe haberse actualizado (tiene más frames que el anterior)
    nuevo_esp = palabra.reload.espectrograma
    assert_equal 3, nuevo_esp["frames"].length,
                 "El nuevo espectrograma debe tener 3 frames"
  end

  test "PUT /palabras/:id con tipo inválido devuelve 422" do
    palabra = palabras(:hola_klingon)

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto: palabra.texto,
            tipo:  "tipo_invalido"
          }
        }.to_json,
        headers: HEADERS

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body.key?("errors"), "Debe devolver errores de validación"
  end

  test "PUT /palabras/:id con texto vacío devuelve 422" do
    palabra = palabras(:hola_klingon)

    put "/palabras/#{palabra.id}",
        params: {
          palabra: {
            texto: "",
            tipo:  palabra.tipo
          }
        }.to_json,
        headers: HEADERS

    assert_response :unprocessable_entity
  end

  test "PUT /palabras/:id con id inexistente devuelve 404" do
    put "/palabras/999999999",
        params:  { palabra: { texto: "nada", tipo: "verbo" } }.to_json,
        headers: HEADERS

    assert_response :not_found
  end

  # ===========================================================================
  # DELETE /palabras/:id
  # ===========================================================================

  test "DELETE /palabras/:id elimina la palabra y devuelve 204" do
    palabra = palabras(:hola_klingon)

    assert_difference "Palabra.count", -1 do
      delete "/palabras/#{palabra.id}", headers: HEADERS
    end

    assert_response :no_content
    assert_not Palabra.exists?(palabra.id),
               "La palabra no debe existir tras el DELETE"
  end

  test "DELETE /palabras/:id no afecta al lenguaje contenedor" do
    palabra  = palabras(:hola_klingon)
    lang_id  = palabra.lenguaje_id

    delete "/palabras/#{palabra.id}", headers: HEADERS

    assert_response :no_content
    assert Lenguaje.exists?(lang_id),
           "El lenguaje debe seguir existiendo tras borrar su palabra"
  end

  test "DELETE /palabras/:id con id inexistente devuelve 404" do
    delete "/palabras/999999999", headers: HEADERS

    assert_response :not_found
  end

  # ===========================================================================
  # FLUJO COMPLETO END-TO-END (solo palabras)
  # ===========================================================================

  test "Flujo completo: crear → leer → actualizar → eliminar una palabra" do
    lenguaje = lenguajes(:elvish)

    # 1. Crear palabra
    post "/lenguajes/#{lenguaje.id}/palabras",
         params: {
           palabra: {
             texto:        "elen",
             tipo:         "sustantivo",
             duracion:     1.1,
             espectrograma: ESPECTROGRAMA_A
           }
         }.to_json,
         headers: HEADERS

    assert_response :created
    palabra_id = JSON.parse(response.body)["id"]
    assert_not_nil palabra_id

    # 2. Leer la palabra creada
    get "/palabras/#{palabra_id}", headers: HEADERS
    assert_response :ok
    assert_equal "elen", JSON.parse(response.body)["texto"]

    # 3. Actualizar la palabra
    put "/palabras/#{palabra_id}",
        params: {
          palabra: {
            texto:        "elenion",
            tipo:         "sustantivo",
            espectrograma: ESPECTROGRAMA_B
          }
        }.to_json,
        headers: HEADERS

    assert_response :ok
    assert_equal "elenion", JSON.parse(response.body)["texto"]

    # 4. Verificar persistencia del cambio
    get "/palabras/#{palabra_id}", headers: HEADERS
    assert_equal "elenion", JSON.parse(response.body)["texto"]

    # 5. Eliminar la palabra
    delete "/palabras/#{palabra_id}", headers: HEADERS
    assert_response :no_content

    # 6. Verificar que ya no existe
    get "/palabras/#{palabra_id}", headers: HEADERS
    assert_response :not_found
  end
end
