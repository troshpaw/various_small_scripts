@ECHO OFF
CHCP 65001 >nul
SET COPYCMD=Y

REM Добавлено отображение информации о процессе копирования файлов:
:: общее количество файлов
:: оставшееся количество файлов
:: объем переданного трафика
:: скорость передачи данных в режиме реального времени.

REM Включение сетевого интерфейса Ethernet0
netsh interface set interface "Ethernet0" admin=ENABLED
TIMEOUT /T 15

REM Установка переменных логина и пароля (использовать "", если есть спец. символы)
REM *********ATTENTION*********
REM Изменить логин и пароль!
SET USERNAME=your_password_in_english/russian
SET PASSWORD=your_password_in_english/russian

REM Подключение к сетевому ресурсу с использованием логина и пароля
REM *********ATTENTION*********
REM Изменить ip-адрес и путь!
net use w: \\x.x.x.x\PATH /user:%USERNAME% %PASSWORD%

REM Проверка успешности подключения
IF NOT %ERRORLEVEL%==0 (
    ECHO Ошибка подключения к сетевому ресурсу. Проверьте логин, пароль или доступность сети.
    EXIT /B 1
)

REM Подсчёт общего количества файлов
SET TOTAL_FILES=0
FOR /F %%A IN ('DIR /B /A-D w:\ ^| FIND /C ":"') DO SET TOTAL_FILES=%%A

REM Начало копирования файлов
SET COPIED_FILES=0
SET TOTAL_SIZE=0
SET START_TIME=%TIME%

REM Получение текущей даты в формате ГГГГ-ММ-ДД для использования с forfiles
FOR /F "tokens=2 delims==" %%D IN ('wmic os get localdatetime /value') DO SET DATETIME=%%D
SET CURR_DATE=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%

REM Цикл копирования и отображения информации
FORFILES /P w:\ /D %CURR_DATE% /C "cmd /c call :COPYFILE @path"

REM Отключение сетевого диска
net use w: /delete

REM Отключение сетевого интерфейса
netsh interface set interface "Ethernet0" admin=DISABLED

REM Успешное завершение
ECHO Файлы успешно скопированы.

GOTO :EOF

:COPYFILE
SET /A COPIED_FILES+=1

REM Копирование файла и получение его размера в байтах
SET FILE_SIZE=0
FOR %%F IN (%1) DO SET FILE_SIZE=%%~zF
SET /A TOTAL_SIZE+=FILE_SIZE

REM *********ATTENTION*********
REM Изменить букву диска и путь!
COPY %1 LETTER_DISK:\PATH\*.*

REM Подсчет оставшихся файлов
SET /A REMAINING_FILES=TOTAL_FILES-COPIED_FILES

REM Подсчёт процента завершения
SET /A PERCENTAGE=(COPIED_FILES*100)/TOTAL_FILES

REM Конвертация байтов в мегабайты
SET /A TOTAL_SIZE_MB=TOTAL_SIZE/1048576

REM Вычисление времени копирования
SET END_TIME=%TIME%
CALL :CALCTIMEDELTA %START_TIME% %END_TIME%

REM Подсчёт скорости копирования
SET /A SPEED_MBPS=TOTAL_SIZE_MB*8/TIME_DELTA

CLS
ECHO ===============================
ECHO Файлов скопировано: %COPIED_FILES% из %TOTAL_FILES%
ECHO Осталось файлов: %REMAINING_FILES%
ECHO Общий размер копий: %TOTAL_SIZE_MB% МБ
ECHO Процент завершения: %PERCENTAGE% %%
ECHO Скорость копирования: %SPEED_MBPS% Мбит/с
ECHO ===============================

EXIT /B

:CALCTIMEDELTA
REM Вычисление разницы во времени между началом и окончанием процесса
SETLOCAL ENABLEDELAYEDEXPANSION
SET START_HOUR=!%1:~0,2!
SET START_MIN=!%1:~3,2!
SET START_SEC=!%1:~6,2!
SET END_HOUR=!%2:~0,2!
SET END_MIN=!%2:~3,2!
SET END_SEC=!%2:~6,2!

SET /A START_TOTAL_SEC=START_HOUR*3600+START_MIN*60+START_SEC
SET /A END_TOTAL_SEC=END_HOUR*3600+END_MIN*60+END_SEC

SET /A TIME_DELTA=END_TOTAL_SEC-START_TOTAL_SEC
IF !TIME_DELTA! LSS 0 SET /A TIME_DELTA+=86400

ENDLOCAL & SET TIME_DELTA=%TIME_DELTA%
EXIT /B