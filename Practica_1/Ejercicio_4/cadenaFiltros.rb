class CadenaFiltros
    @@filtros = []
    @@target
    def agregar_filtro(filtro)
        @@filtros << filtro
    end

    def set_target(target)
        @@target = target
    end

    def get_filtros()
        return @@filtros
    end

    def execute(string)
        for filtro in @@filtros
            if !filtro.filtrar(string)
                @@target.non_execute(string)
                return
            end
        end
        if @@target != nil
            @@target.execute(string)
        else
            puts "No se ha establecido un target"
        end
    end
end