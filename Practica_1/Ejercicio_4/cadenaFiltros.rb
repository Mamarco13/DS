class CadenaFiltros
    @filtros
    @target

    def initialize()
        @filtros = []
    end
    def agregar_filtro(filtro)
        @filtros << filtro
    end

    def set_target(target)
        @target = target
    end

    def get_filtros()
        return @filtros
    end

    def execute(string)
        for filtro in @filtros
            if !filtro.filtrar(string)
                @target.non_execute(string)
                return false
            end
        end
        if @target != nil
            @target.execute(string)
            return true
        else
            puts "No se ha establecido un target"
            return false
        end
    end
end