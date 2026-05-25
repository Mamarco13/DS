class PalabrasController < ApplicationController

    before_action :set_lenguaje, only: [:index, :create]
    before_action :set_palabra, only: [:show, :update, :destroy]

    def index
        render json: @lenguaje.palabras
    end

    def show
        render json: @palabra
    end

    def create
        palabra = @lenguaje.palabras.new(palabra_params)
        if palabra.save
            render json: palabra, status: :created
        else
            render json: { errors: palabra.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        if @palabra.update(palabra_params)
            render json: @palabra
        else
            render json: { errors: @palabra.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @palabra.destroy
        head :no_content
    end

    private

    def set_lenguaje
        @lenguaje = Lenguaje.find(params[:lenguaje_id])
    end

    def set_palabra
        @palabra = @lenguaje.palabras.find(params[:id])
    end

    def palabra_params
        base = params.require(:palabra).permit(:texto, :tipo, :duracion)
        espectrograma = params.dig(:palabra, :espectrograma)
        base[:espectrograma] = espectrograma.to_unsafe_hash if espectrograma.present?
        base
    end
end
