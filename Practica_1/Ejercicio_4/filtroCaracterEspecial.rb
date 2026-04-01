class FiltroCaracterEspecial include IFiltro
    def filtrar(string)
        if string.include?("!") or string.include?("#") or string.include?("$") or string.include?("%") or string.include?("&") or string.include?("*") or string.include?("+") or string.include?("-") or string.include?("/") or string.include?("=") or string.include?("?") or string.include?("^") or string.include?("_") or string.include?("`") or string.include?("{") or string.include?("|") or string.include?("}") or string.include?("~") or string.include?(".") or string.include?(",") or string.include?(";") or string.include?(":") or string.include?("'") or string.include?("\"") or string.include?("<") or string.include?(">") or string.include?("[") or string.include?("]")
            return true
        else
            return false
        end
    end
end