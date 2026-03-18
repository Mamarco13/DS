require_relative "cadenaFiltros"

class ManagerFiltros
    @cadenaFiltros

    def initialize (cadenaFiltros)
        @cadenaFiltros = cadenaFiltros
    end

    def initialize(target)
        @cadenaFiltros = CadenaFiltros.new
        @cadenaFiltros.set_target(target)
    end

    def agregar_filtro(filtro)
        @cadenaFiltros.agregar_filtro(filtro)
    end

    def execute(string)
        @cadenaFiltros.execute(string)
    end

    def get_filtros()
        return @cadenaFiltros.get_filtros()
    end

end