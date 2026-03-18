require 'json'
class ContraseniaAntigua include IFiltro
    def filtrar(string)
        contenido = JSON.parse(File.read("contrasenias.json"))
        if contenido["Contrasenias"].include?(string)
            return false
        else
            return true
        end
    end
end