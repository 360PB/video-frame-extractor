@echo off
setlocal enabledelayedexpansion
cls

:: ���ÿ���̨��ɫ
color 0B

:: ���ⲿ��
color 1F
echo ================================================
echo             conda�������ù���
echo ================================================
color 0B
echo ------------------------------------------------                  
echo              Version: 1.0.0                      
echo              ����: ��ӣ�κ�                      
echo ------------------------------------------------  
echo.
color 0A
echo ************************************************
echo            ��ʼִ�л������...
echo ************************************************
echo.
timeout /t 2 >nul

:: ѯ���Ƿ�ʹ�þ���Ĭ��ʹ���廪Դ��
color 0E
echo ------------------------------------------------
echo              ϵͳ���� - ����ѡ��
echo ------------------------------------------------
set /p USE_MIRROR="�Ƿ�ʹ���廪������ѡ�� [Y]�� [N]��Ĭ�ϣ�Y����"

:: ����û�û�����룬����Ĭ��ֵΪY
if "%USE_MIRROR%"=="" set USE_MIRROR=Y

:: �����û�ѡ������USE_MIRROR����
if /i "%USE_MIRROR%"=="Y" (
    set USE_MIRROR=true
    echo [�������] ʹ���廪����Դ
) else (
    set USE_MIRROR=false
    echo [�������] ʹ�ùٷ�Դ
)
echo.

:: �����ǽű������ಿ�֣����ֲ���...

:: ��װĿ¼����
color 0B
set Git_DIR=%cd%
set INSTALL_DIR=%cd%\tools
set CONDA_ROOT_PREFIX=%INSTALL_DIR%\conda
set INSTALL_ENV_DIR=%INSTALL_DIR%\env

echo ------------------------------------------------
echo                  ������Ϣ
echo ------------------------------------------------
echo ��Ŀ¼��%INSTALL_DIR%
echo CondaĿ¼��%CONDA_ROOT_PREFIX%
echo ����Ŀ¼��%INSTALL_ENV_DIR%
echo.

:: ��鵱ǰ·���е������ַ�
color 0C
echo [ϵͳ���] ���·���Ϸ���...
echo "%CD%" | findstr /R /C:"[!#\$%&()\*+,;<=>?@\[\]\^`{|}~\u4E00-\u9FFF[:space:] ]" >nul && (
    echo ------------------------------------------------
    echo                  ������Ϣ
    echo ------------------------------------------------
    echo ��⵽��Ч·����
    echo - ·���в��ܰ��������ַ�
    echo - ·���в��ܰ����ո�
    echo - ·���в��ܰ��������ַ�
    echo ��ǰ·����"%CD%"
    echo [��ʾ] �뽫�ű��ƶ�����Ч·���£����磺D:\pythonenv�������ԡ�
    goto end
) || (
    color 0A
    echo [�ɹ�] ·�����ͨ��
)
echo.

:: ����Miniconda���ص�ַ
if "%USE_MIRROR%" == "true" (
    set MINICONDA_DOWNLOAD_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Windows-x86_64.exe
) else (
    set MINICONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
)

:: �� Miniconda ���֮ǰ��� curl ����߼�
color 0D
echo ------------------------------------------------
echo                  CURL ���
echo ------------------------------------------------

:: ���� curl ·��
set CURL_PATH=%cd%\tools\curl\bin
set PATH=%CURL_PATH%;%PATH%

:: ��֤ curl �Ƿ����
echo [���] ��� curl �Ƿ����...
curl --version >nul 2>&1
if errorlevel 1 (
    :: curl �����ڣ�����ʹ������ curl
    echo [��Ϣ] ϵͳ curl δ�ҵ�����鱾�� curl...
    if not exist "%CURL_PATH%\curl.exe" (
        echo [����] ���� curl ����δ�ҵ�
        echo [��ʾ] ��ȷ������·�����ڣ�
        echo        %CURL_PATH%\curl.exe
        goto end
    ) else (
        echo [�ɹ�] �ҵ����� curl ����
        echo [��Ϣ] curl �汾��Ϣ��
        "%CURL_PATH%\curl.exe" --version
    )
) else (
    color 0A
    echo [�ɹ�] ϵͳ curl ����
    echo [��Ϣ] curl �汾��Ϣ��
    curl --version
)
echo.

:: ���Miniconda�Ƿ��Ѱ�װ
color 0D
echo ------------------------------------------------
echo              Miniconda ���
echo ------------------------------------------------
call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
if errorlevel 1 (
    echo [��װ] δ��⵽Miniconda����ʼ����...
    mkdir "%INSTALL_DIR%" 2>nul
    
    :: ʹ�� curl ���� Miniconda
    echo [����] �������� Miniconda...
    if exist "%CURL_PATH%\curl.exe" (
        "%CURL_PATH%\curl.exe" -Lk "%MINICONDA_DOWNLOAD_URL%" -o "%INSTALL_DIR%\miniconda_installer.exe"
    ) else (
        curl -Lk "%MINICONDA_DOWNLOAD_URL%" -o "%INSTALL_DIR%\miniconda_installer.exe"
    )
    
    if errorlevel 1 (
        color 0C
        echo [����] Miniconda����ʧ��
        goto end
    )

    echo [������] ���ڰ�װMiniconda...
    start /wait "" "%INSTALL_DIR%\miniconda_installer.exe" /InstallationType=JustMe /NoShortcuts=1 /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%CONDA_ROOT_PREFIX%

    call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
    if errorlevel 1 (
        color 0C
        echo [����] Miniconda��װʧ��
        goto end
    )
    color 0A
    echo [���] Miniconda��װ�ɹ���
    del "%INSTALL_DIR%\miniconda_installer.exe"
) else (
    color 0A
    echo [���] �Ѽ�⵽Miniconda��װ
)
echo.

:: ��黷���Ƿ����
color 0B
echo ------------------------------------------------
echo                �������
echo ------------------------------------------------
if exist "%INSTALL_ENV_DIR%\python.exe" (
    echo [���] �����Ѵ��ڵ�Conda����
    echo [������] ���ڼ����...
    call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
    if errorlevel 1 (
        color 0C
        echo [����] ��������ʧ��
        goto end
    )
    color 0A
    echo [���] ��������ɹ���
    echo.
    echo ------------------------------------------------
    echo                ��������
    echo ------------------------------------------------
    echo [��ʾ] ʹ���廪����Դ��ִ�У�
    echo pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    cmd /k
    goto :EOF
)

:: ������������ڣ������»���
color 0E
echo [��Ϣ] δ��⵽Conda������׼������...
echo.
echo ------------------------------------------------
echo              Python�汾ѡ��
echo ------------------------------------------------
set /p PYTHON_VERSION="������Python�汾��Ĭ��Ϊ3.10����"
if "%PYTHON_VERSION%"=="" set PYTHON_VERSION=3.10
echo [����] ѡ���Python�汾��%PYTHON_VERSION%
echo.

:: �����µĻ���
echo [������] ���ڴ���Conda����...
if "%USE_MIRROR%" == "true" (
    call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ python=%PYTHON_VERSION%
) else (
    call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" python=%PYTHON_VERSION%
)

if errorlevel 1 (
    color 0C
    echo [����] ��������ʧ��
    goto end
)

:: �����
color 0B
echo [������] ���ڼ����»���...
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
if errorlevel 1 (
    color 0C
    echo [����] ��������ʧ��
    goto end
)
color 0A
echo [���] ��������������ɹ���
echo.
echo ------------------------------------------------
echo                ��������
echo ------------------------------------------------
echo [��ʾ] ʹ���廪����Դ��ִ�У�
echo pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
cmd /k

:end
echo.
color 0C
echo ================================================
echo              �������ù����ж�
echo ================================================
pause
goto :EOF
