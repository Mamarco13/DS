class FiltroLongitud < IFiltro
    def filtrar(string)
        if string.length >= 4
            puts "La contraseña es válida"
            return true
        else
            puts "La contraseña no es válida"
            return false
        end
    end
end