@echo off
title Entorno de Desarrollo Traductor Universal

:: Directorio raiz del proyecto (donde esta este .bat)
set PROJECT_ROOT=%~dp0

:: Convertir ruta Windows a ruta WSL (ej: C:\ -> /mnt/c/) usando PowerShell para garantizar minusculas
for /f "delims=" %%i in ('powershell -nologo -noprofile -command "$p='%PROJECT_ROOT%'; '/mnt/' + $p[0].ToString().ToLower() + '/' + $p.Substring(3).Replace('\','/')"') do set WSL_PROJECT_ROOT=%%i

echo ========================================================
echo   Iniciando Servidor Ruby on Rails (Backend) en WSL...
echo ========================================================
:: Abre una nueva ventana de terminal ejecutando el servidor de Rails en la ruta de WSL.
:: Eliminamos el archivo server.pid por si el servidor se cerró mal anteriormente.
start "Rails Server" wsl -- bash -lic "cd '%WSL_PROJECT_ROOT%Practica_4.2/salvacion_bd' && rm -f tmp/pids/server.pid && echo 'Iniciando Rails...' && bundle exec rails s; exec bash"

echo.
echo ========================================================
echo   Iniciando Aplicacion Flutter (Frontend) en Windows...
echo ========================================================
:: Cambia al directorio de la app y ejecuta Flutter forzando el dispositivo a 'windows'
cd /d "%PROJECT_ROOT%Practica_4\salvacion_app"
flutter run -d windows

echo.
echo Cerrando script principal...
pause
