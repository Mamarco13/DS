require_relative "IFiltro"
require_relative "filtroArroba"
require_relative "filtroDominio"
require_relative "filtroLongitud"
require_relative "filtroCaracterEspecial"
require_relative "filtroContraseniaAntigua"
require_relative "target"
require_relative "managerFiltros"
require_relative "filtroContraseniaAntigua"
require_relative "filtroCaracterEspecial"
require_relative "cadenaFiltros"


managerFiltros = ManagerFiltros.new(Target.new)
managerFiltros.agregar_filtro(FiltroArroba.new)
managerFiltros.agregar_filtro(FiltroDominio.new)
managerFiltros2 = ManagerFiltros.new(Target.new)
managerFiltros2.agregar_filtro(ContraseniaAntigua.new)
managerFiltros2.agregar_filtro(FiltroCaracterEspecial.new)
managerFiltros2.agregar_filtro(FiltroLongitud.new)
puts "Ingrese una usuario para validar:"
usuario = gets.chomp
if managerFiltros.execute(usuario) == true
    puts "Ingrese una contraseña para validar:"
    contrasenia = gets.chomp
    managerFiltros2.execute(contrasenia)
end