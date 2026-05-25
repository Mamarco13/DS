class LenguajesController < ApplicationController
    before_action :set_lenguaje, only: [:show, :update, :destroy, :buscar]


    def index
        render json: Lenguaje.all
    end

    def show
        render json: @lenguaje
    end

    def create
        lenguaje = Lenguaje.new(lenguaje_params)
        if lenguaje.save
            render json: lenguaje, status: :created
        else
            render json: { errors: lenguaje.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        if @lenguaje.update(lenguaje_params)
            render json: @lenguaje
        else
            render json: { errors: @lenguaje.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @lenguaje.destroy
        head :no_content
    end

    def buscar
  frames_input = params[:espectrograma]&.dig("frames")

  if frames_input.nil?
    render json: { error: "Falta el espectrograma" }, status: :bad_request
    return
  end

  mejor_palabra = nil
  mejor_similitud = -1.0

  @lenguaje.palabras.each do |palabra|
    frames_guardados = palabra.espectrograma&.dig("frames")
    next if frames_guardados.nil?

    s = ComparadorEspectrograma.similitud(frames_input, frames_guardados)

    if s > mejor_similitud
      mejor_similitud = s
      mejor_palabra = palabra
    end
  end

  if mejor_palabra.nil? || mejor_similitud < ComparadorEspectrograma::UMBRAL
    render json: { palabra: "unknown", tipo: "otro", duracion: 0 }
  else
    duracion_ratio = mejor_palabra.duracion&.positive? ?
      (frames_input.length.to_f / mejor_palabra.duracion) : 0.0

    render json: {
      palabra: mejor_palabra.texto,
      tipo:    mejor_palabra.tipo,
      duracion: duracion_ratio.round(3)
    }
  end
end


    private

    def set_lenguaje
        @lenguaje = Lenguaje.find(params[:id])
    end

    def lenguaje_params
        params.require(:lenguaje).permit(:nombre)
    end
end
