@echo off
setlocal enabledelayedexpansion

:: ���ð�װĿ¼Ϊ��ǰĿ¼�µ�DH_live�ļ���
set Git_DIR=%cd%
set INSTALL_DIR=%Git_DIR%\tools

:: ��鵱ǰ·���е������ַ����ո�������ַ�
echo "%CD%"| findstr /R /C:"[!#\$%&()\*+,;<=>?@\[\]\^`{|}~\u4E00-\u9FFF ] " >nul && (
    echo.
    echo ���󣺼�⵽��Ч·����
    echo 1. ·���в��ܰ��������ַ�
    echo 2. ·���в��ܰ����ո�
    echo 3. ·���в��ܰ��������ַ�
    echo ��ǰ·����"%CD%"
    echo �뽫�ű��ƶ�����Ч·�������磺D:\pythonenv�������ԡ�
    goto end
)

:: ���û�������PATH�����FFmpeg��·��
set "PATH=%PATH%;%Git_DIR%\tools\ffmpeg-7.1\bin"

:: ����Conda·��

SET CONDA_PATH=%INSTALL_DIR%\conda
set INSTALL_ENV_DIR=%INSTALL_DIR%\env



:: ����base����
CALL %CONDA_PATH%\Scripts\activate.bat %INSTALL_ENV_DIR%


cd /d %Git_DIR%



python app.py

:end
@cmd