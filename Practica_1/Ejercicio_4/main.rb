require_relative "IFiltro"
require_relative "filtroArroba"
require_relative "filtroDominio"
require_relative "filtroLongitud"
require_relative "filtroCaracterEspecial"
require_relative "filtroContraseniaAntigua"
require_relative "target"
require_relative "cliente"
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
puts managerFiltros.get_filtros().length()                                  #ES CULPA DE @@filtros
puts managerFiltros2.get_filtros().length()                                 #MIRA POR AHI, QUIZAS HAY QUE CAMBIAR TODOS LOS @@ por @
cliente = Cliente.new
puts "Ingrese una usuario para validar:"
usuario = gets.chomp
cliente.execute(usuario, managerFiltros)
puts "Ingrese una contraseña para validar:"
contrasenia = gets.chomp
cliente.execute(contrasenia, managerFiltros2)