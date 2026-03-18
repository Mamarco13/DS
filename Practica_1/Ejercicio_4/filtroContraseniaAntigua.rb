class ContraseniaAntigua < IFiltro
    def filtrar(string)
        if string == "contrasenia123"
            return false
        else
            return true
        end
    end
end