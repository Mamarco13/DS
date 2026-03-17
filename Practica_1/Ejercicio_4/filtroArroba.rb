class FiltroArroba < IFiltro
    def filtrar(string)
        if string.include?("@")
            return true
        else
            return false
        end
    end
end