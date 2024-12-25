@echo off
setlocal enabledelayedexpansion
cls

:: 设置控制台颜色
color 0B

:: 标题部分
color 1F
echo ================================================
echo             conda环境配置工具
echo ================================================
color 0B
echo ------------------------------------------------                  
echo              Version: 1.0.0                      
echo              制作: 云樱梦海                      
echo ------------------------------------------------  
echo.
color 0A
echo ************************************************
echo            开始执行环境检测...
echo ************************************************
echo.
timeout /t 2 >nul

:: 询问是否使用镜像（默认使用清华源）
color 0E
echo ------------------------------------------------
echo              系统配置 - 镜像选择
echo ------------------------------------------------
set /p USE_MIRROR="是否使用清华镜像？请选择 [Y]是 [N]否（默认：Y）："

:: 如果用户没有输入，设置默认值为Y
if "%USE_MIRROR%"=="" set USE_MIRROR=Y

:: 根据用户选择设置USE_MIRROR变量
if /i "%USE_MIRROR%"=="Y" (
    set USE_MIRROR=true
    echo [配置完成] 使用清华镜像源
) else (
    set USE_MIRROR=false
    echo [配置完成] 使用官方源
)
echo.

:: 以下是脚本的其余部分，保持不变...

:: 安装目录设置
color 0B
set Git_DIR=%cd%
set INSTALL_DIR=%cd%\tools
set CONDA_ROOT_PREFIX=%INSTALL_DIR%\conda
set INSTALL_ENV_DIR=%INSTALL_DIR%\env

echo ------------------------------------------------
echo                  环境信息
echo ------------------------------------------------
echo 主目录：%INSTALL_DIR%
echo Conda目录：%CONDA_ROOT_PREFIX%
echo 环境目录：%INSTALL_ENV_DIR%
echo.

:: 检查当前路径中的特殊字符
color 0C
echo [系统检测] 检查路径合法性...
echo "%CD%" | findstr /R /C:"[!#\$%&()\*+,;<=>?@\[\]\^`{|}~\u4E00-\u9FFF[:space:] ]" >nul && (
    echo ------------------------------------------------
    echo                  错误信息
    echo ------------------------------------------------
    echo 检测到无效路径！
    echo - 路径中不能包含特殊字符
    echo - 路径中不能包含空格
    echo - 路径中不能包含中文字符
    echo 当前路径："%CD%"
    echo [提示] 请将脚本移动到有效路径下（例如：D:\pythonenv）后重试。
    goto end
) || (
    color 0A
    echo [成功] 路径检查通过
)
echo.

:: 设置Miniconda下载地址
if "%USE_MIRROR%" == "true" (
    set MINICONDA_DOWNLOAD_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Windows-x86_64.exe
) else (
    set MINICONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
)

:: 在 Miniconda 检测之前添加 curl 检测逻辑
color 0D
echo ------------------------------------------------
echo                  CURL 检测
echo ------------------------------------------------

:: 设置 curl 路径
set CURL_PATH=%cd%\tools\curl\bin
set PATH=%CURL_PATH%;%PATH%

:: 验证 curl 是否存在
echo [检测] 检查 curl 是否可用...
curl --version >nul 2>&1
if errorlevel 1 (
    :: curl 不存在，尝试使用内置 curl
    echo [信息] 系统 curl 未找到，检查本地 curl...
    if not exist "%CURL_PATH%\curl.exe" (
        echo [错误] 本地 curl 工具未找到
        echo [提示] 请确保以下路径存在：
        echo        %CURL_PATH%\curl.exe
        goto end
    ) else (
        echo [成功] 找到本地 curl 工具
        echo [信息] curl 版本信息：
        "%CURL_PATH%\curl.exe" --version
    )
) else (
    color 0A
    echo [成功] 系统 curl 可用
    echo [信息] curl 版本信息：
    curl --version
)
echo.

:: 检查Miniconda是否已安装
color 0D
echo ------------------------------------------------
echo              Miniconda 检测
echo ------------------------------------------------
call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
if errorlevel 1 (
    echo [安装] 未检测到Miniconda，开始下载...
    mkdir "%INSTALL_DIR%" 2>nul
    
    :: 使用 curl 下载 Miniconda
    echo [下载] 正在下载 Miniconda...
    if exist "%CURL_PATH%\curl.exe" (
        "%CURL_PATH%\curl.exe" -Lk "%MINICONDA_DOWNLOAD_URL%" -o "%INSTALL_DIR%\miniconda_installer.exe"
    ) else (
        curl -Lk "%MINICONDA_DOWNLOAD_URL%" -o "%INSTALL_DIR%\miniconda_installer.exe"
    )
    
    if errorlevel 1 (
        color 0C
        echo [错误] Miniconda下载失败
        goto end
    )

    echo [进行中] 正在安装Miniconda...
    start /wait "" "%INSTALL_DIR%\miniconda_installer.exe" /InstallationType=JustMe /NoShortcuts=1 /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%CONDA_ROOT_PREFIX%

    call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
    if errorlevel 1 (
        color 0C
        echo [错误] Miniconda安装失败
        goto end
    )
    color 0A
    echo [完成] Miniconda安装成功！
    del "%INSTALL_DIR%\miniconda_installer.exe"
) else (
    color 0A
    echo [完成] 已检测到Miniconda安装
)
echo.

:: 检查环境是否存在
color 0B
echo ------------------------------------------------
echo                环境检测
echo ------------------------------------------------
if exist "%INSTALL_ENV_DIR%\python.exe" (
    echo [检测] 发现已存在的Conda环境
    echo [进行中] 正在激活环境...
    call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
    if errorlevel 1 (
        color 0C
        echo [错误] 环境激活失败
        goto end
    )
    color 0A
    echo [完成] 环境激活成功！
    echo.
    echo ------------------------------------------------
    echo                环境就绪
    echo ------------------------------------------------
    echo [提示] 使用清华镜像源请执行：
    echo pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    cmd /k
    goto :EOF
)

:: 如果环境不存在，创建新环境
color 0E
echo [信息] 未检测到Conda环境，准备创建...
echo.
echo ------------------------------------------------
echo              Python版本选择
echo ------------------------------------------------
set /p PYTHON_VERSION="请输入Python版本（默认为3.10）："
if "%PYTHON_VERSION%"=="" set PYTHON_VERSION=3.10
echo [配置] 选择的Python版本：%PYTHON_VERSION%
echo.

:: 创建新的环境
echo [进行中] 正在创建Conda环境...
if "%USE_MIRROR%" == "true" (
    call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ python=%PYTHON_VERSION%
) else (
    call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" python=%PYTHON_VERSION%
)

if errorlevel 1 (
    color 0C
    echo [错误] 环境创建失败
    goto end
)

:: 激活环境
color 0B
echo [进行中] 正在激活新环境...
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
if errorlevel 1 (
    color 0C
    echo [错误] 环境激活失败
    goto end
)
color 0A
echo [完成] 环境创建并激活成功！
echo.
echo ------------------------------------------------
echo                环境就绪
echo ------------------------------------------------
echo [提示] 使用清华镜像源请执行：
echo pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
cmd /k

:end
echo.
color 0C
echo ================================================
echo              环境配置过程中断
echo ================================================
pause
goto :EOF
