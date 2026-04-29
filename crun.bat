@echo off
REM Flutter web'i CORS-disabled Chrome ile baslatir.
REM Token .env'den asset olarak yuklenir (flutter_dotenv). Ekstra parametre gerekmez.
REM
REM Kullanim:  crun
REM Opsiyonel: crun 9000   (farkli port)

setlocal

set PORT=%1
if "%PORT%"=="" set PORT=8765

REM Her run'da farkli bir Chrome profil dizini, eski oturumla cakismasin
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HHmmss"') do set STAMP=%%i
set USERDIR=C:\temp\cr-flutter-%STAMP%
if not exist "%USERDIR%" mkdir "%USERDIR%"

if not exist ".env" (
    echo HATA: .env dosyasi bulunamadi.
    echo .env.example dosyasini .env olarak kopyala ve CR_API_TOKEN'i yapistir.
    exit /b 1
)

echo Flutter web baslatiliyor (port %PORT%)...
flutter run -d chrome ^
    --web-port=%PORT% ^
    --web-browser-flag=--disable-web-security ^
    --web-browser-flag=--user-data-dir=%USERDIR%

endlocal
