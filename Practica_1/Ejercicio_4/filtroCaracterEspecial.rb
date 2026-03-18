class FiltroCaracterEspecial < IFiltro
    def filtrar(string)
        if string.include?("!") or string.include?("#") or string.include?("$") or string.include?("%") or string.include?("&") or string.include?("*") or string.include?("+") or string.include?("-") or string.include?("/") or string.include?("=") or string.include?("?") or string.include?("^") or string.include?("_") or string.include?("`") or string.include?("{") or string.include?("|") or string.include?("}") or string.include?("~") or string.include?(".") or string.include?(",") or string.include?(";") or string.include?(":") or string.include?("'") or string.include?("\"") or string.include?("<") or string.include?(">") or string.include?("[") or string.include?("]")
            puts "La contraseña es válida3"
            return true
        else
            puts "La contraseña no es válida3"
            return false
        end
    end
end