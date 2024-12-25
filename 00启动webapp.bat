@echo off
setlocal enabledelayedexpansion

:: 设置安装目录为当前目录下的DH_live文件夹
set Git_DIR=%cd%
set INSTALL_DIR=%Git_DIR%\tools

:: 检查当前路径中的特殊字符、空格和中文字符
echo "%CD%"| findstr /R /C:"[!#\$%&()\*+,;<=>?@\[\]\^`{|}~\u4E00-\u9FFF ] " >nul && (
    echo.
    echo 错误：检测到无效路径。
    echo 1. 路径中不能包含特殊字符
    echo 2. 路径中不能包含空格
    echo 3. 路径中不能包含中文字符
    echo 当前路径："%CD%"
    echo 请将脚本移动到有效路径（例如：D:\pythonenv）后再试。
    goto end
)

:: 设置环境变量PATH，添加FFmpeg的路径
set "PATH=%PATH%;%Git_DIR%\tools\ffmpeg-7.1\bin"

:: 设置Conda路径

SET CONDA_PATH=%INSTALL_DIR%\conda
set INSTALL_ENV_DIR=%INSTALL_DIR%\env



:: 激活base环境
CALL %CONDA_PATH%\Scripts\activate.bat %INSTALL_ENV_DIR%


cd /d %Git_DIR%



python app.py

:end
@cmd