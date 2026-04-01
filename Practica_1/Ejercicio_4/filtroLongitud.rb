class FiltroLongitud include IFiltro
    def filtrar(string)
        if string.length >= 4
            return true
        else
            return false
        end
    end
end