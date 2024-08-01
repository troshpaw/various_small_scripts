@ECHO OFF
CHCP 65001 >nul
SET COPYCMD=Y

REM Добавлено измерение скорости копирования

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

REM Начало отсчета времени копирования
SET START_TIME=%TIME%

REM Копирование файлов с текущей датой и подсчет общего размера
SET TOTAL_SIZE=0

FORFILES /P w:\ /D %date% /C "cmd /c call :COPY_AND_MEASURE @path"

REM Завершение копирования
ECHO Все файлы успешно скопированы.

REM Отключение сетевого диска
net use w: /delete

REM Отключение сетевого интерфейса
netsh interface set interface "Ethernet0" admin=DISABLED

REM Завершение
GOTO :EOF

:COPY_AND_MEASURE
REM Получение размера текущего файла
FOR %%F IN (%1) DO SET FILE_SIZE=%%~zF

REM Копирование файла
REM *********ATTENTION*********
REM Изменить букву диска и путь!
COPY %1 DISK_LETTER:\PATH\*.* >nul

REM Обновление общего размера копированных данных
SET /A TOTAL_SIZE+=FILE_SIZE

REM Получение текущего времени после копирования файла
SET END_TIME=%TIME%

REM Вычисление времени и скорости
CALL :CALC_SPEED %START_TIME% %END_TIME% %TOTAL_SIZE%

REM Обновление времени начала для следующего файла
SET START_TIME=%END_TIME%
EXIT /B

:CALC_SPEED
REM Вычисление времени копирования в секундах
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

REM Вычисление скорости в Мбит/с
SET /A SPEED_MBPS=!%3!*8/(TIME_DELTA*1048576)

REM Вывод скорости копирования
ECHO ===============================
ECHO Размер файла: !%3! байт
ECHO Время копирования: !TIME_DELTA! секунд
ECHO Текущая скорость копирования: !SPEED_MBPS! Мбит/с
ECHO ===============================

ENDLOCAL
EXIT /B
