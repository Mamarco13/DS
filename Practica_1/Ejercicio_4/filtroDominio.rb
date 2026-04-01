class FiltroDominio include IFiltro
    def filtrar(string)
        if string.split("@").last == "gmail.com" or string.split("@").last == "hotmail.com"
            return true
        else
            return false
        end
    end
end