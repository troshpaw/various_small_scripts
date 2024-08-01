@ECHO OFF
CHCP 65001 >nul
SET COPYCMD=Y

REM Базовый файл

netsh interface set interface "Ethernet0" admin=ENABLED
TIMEOUT /T 15

REM Установка переменных логина и пароля (использовать "", если есть спец. символы)
SET USERNAME=your_password_in_english/russian
SET PASSWORD=your_password_in_english/russian

REM Подключение к сетевому ресурсу с использованием логина и пароля
net use w: \\x.x.x.x\PATH /user:%USERNAME% %PASSWORD%

REM Проверка успешности подключения
IF NOT %ERRORLEVEL%==0 (
    ECHO Ошибка подключения к сетевому ресурсу. Проверьте логин, пароль или доступность сети.
    EXIT /B 1
)

REM Копирование файлов с текущей датой
forfiles /p w:\ /d %date% /c "cmd /c copy @file LETTER_DISK:\PATH\*.*"

REM Отключение сетевого диска
net use w: /delete

REM Отключение сетевого интерфейса
netsh interface set interface "Ethernet0" admin=DISABLED

REM Успешное завершение
ECHO Файлы успешно скопированы.