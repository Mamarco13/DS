class ContraseniaAntigua < IFiltro
    def filtrar(string)
        if string == "contrasenia123"
            puts "La contraseña no es válida2"
            return false
        else
            puts "La contraseña es válida2"
            return true
        end
    end
end