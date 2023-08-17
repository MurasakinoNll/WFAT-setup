@echo off
setlocal

REM Install Python 3.11
python --version 2>&1 | findstr /I "3.11"
if %ERRORLEVEL% NEQ 0 (
    echo Python 3.11 is not installed. Please install Python 3.11 from the official website.
    exit /b 1
)

REM Install Git
where git > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Git is not installed. Installing Git...
    powershell -Command "Start-Process https://git-scm.com/download/win -Wait"
)

REM Install Node.js and npm
node --version 2>&1 | findstr /I "v"
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Installing Node.js and npm...
    powershell -Command "Start-Process https://nodejs.org/en/download/ -Wait"
)

REM Install Python requests library
pip show requests | findstr /I "Name: requests"
if %ERRORLEVEL% NEQ 0 (
    echo Installing requests...
    pip install requests
)

REM Set the installation directory to the user's home directory
set "repo_dir=%USERPROFILE%\algo-trader"
mkdir "%repo_dir%" 2>nul
cd /d "%repo_dir%"

REM Clone the Git repository into the specified directory
if exist "%repo_dir%\Warframe-Algo-Trader" (
    echo Repository is already cloned in %repo_dir%\Warframe-Algo-Trader.
) else (
    echo Cloning the Git repository into %repo_dir%\Warframe-Algo-Trader...
    git clone https://github.com/akmayer/Warframe-Algo-Trader
)

REM Install Python dependencies
cd "%repo_dir%\Warframe-Algo-Trader"
python -m venv venv
call venv\Scripts\activate
python -m pip install -r requirements.txt

REM Remove the existing config.json file (if it exists)
if exist "config.json" del "config.json"

REM Gather user input
set /p "ign=Enter your in-game name: "
set /p "jwt_token=Enter your JWT token (including 'JWT' prefix if present): "

REM Clean JWT token input (remove 'JWT' prefix if present)
set "jwt_token=%jwt_token:JWT =%"

REM Prompt for missing 'JWT' prefix if not provided
if not "%jwt_token:~0,3%"=="JWT" (
    echo JWT prefix is missing. Adding it to the token.
    set "jwt_token=JWT %jwt_token%"
)

REM Offer platform choice and gather user input
echo Choose your platform:
echo [1] pc
echo [2] ps4
echo [3] xbox
echo [4] switch
set /p platform=Enter the platform number (1/2/3/4): 
if "%platform%"=="1" set platform=pc
if "%platform%"=="2" set platform=ps4
if "%platform%"=="3" set platform=xbox
if "%platform%"=="4" set platform=switch

REM Create config.json
(
    echo {
    echo    "pushbutton_token": "",
    echo    "pushbutton_device_iden": "",
    echo    "inGameName": "%ign%",
    echo    "wfm_jwt_token": "%jwt_token%",
    echo    "runningLiveScraper": false,
    echo    "runningStatisticsScraper": false,
    echo    "runningWarframeScreenDetect": false,
    echo    "platform": "%platform%"
    echo }
) > config.json

echo Installation completed successfully!
pause

REM Restore the previous environment
endlocal
