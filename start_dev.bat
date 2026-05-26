@echo off
title Entorno de Desarrollo Traductor Universal

echo ========================================================
echo   Iniciando Servidor Ruby on Rails (Backend) en WSL...
echo ========================================================
:: Abre una nueva ventana de terminal ejecutando el servidor de Rails en la ruta de WSL.
:: Eliminamos el archivo server.pid por si el servidor se cerró mal anteriormente.
start "Rails Server" wsl -- bash -lic "cd /mnt/c/Users/mamar/Desktop/2Cuatri/DS/Practicas/DS/Practica_4.2/salvacion_bd && rm -f tmp/pids/server.pid && echo 'Iniciando Rails...' && bundle exec rails s; exec bash"

echo.
echo ========================================================
echo   Iniciando Aplicacion Flutter (Frontend) en Windows...
echo ========================================================
:: Cambia al directorio de la app y ejecuta Flutter forzando el dispositivo a 'windows'
cd /d "C:\Users\mamar\Desktop\2Cuatri\DS\Practicas\DS\Practica_4\salvacion_app"
flutter run -d windows

echo.
echo Cerrando script principal...
pause
