@echo off

REM Check if Python 3.11 is installed
python --version 2>&1 | findstr /I "3.11"
if %ERRORLEVEL% NEQ 0 (
    echo Python 3.11 is not installed. Please install Python 3.11 from the official website.
    exit /b 1
)

REM Check if Git is installed
where git > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Git is not installed. Installing Git...
    powershell -Command "Start-Process https://git-scm.com/download/win -Wait"
)

REM Check if Node.js and npm are installed
node --version 2>&1 | findstr /I "v"
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Please install Node.js with npm from the official website.
    exit /b 1
)

REM Check if Python requests library is installed
pip show requests | findstr /I "Name: requests"
if %ERRORLEVEL% NEQ 0 (
    echo Installing requests...
    pip install requests
)

REM Set the installation directory to the user's home directory
set "repo_dir=%USERPROFILE%\algorithm-trader-warframe"
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
pip install -r "%repo_dir%\Warframe-Algo-Trader\requirements.txt"
pip install uvicorn

REM Set the installation directory to the 'my-app' folder
cd /d "%repo_dir%\Warframe-Algo-Trader\my-app"

REM Check if Node.js dependencies are already installed
if exist "node_modules" (
    echo Node.js dependencies are already installed.
) else (
    echo Installing Node.js dependencies...
    npm install --no-fund

    REM Wait for npm installation to complete
    :WAIT_NPM_INSTALL
    if not exist "node_modules" (
        timeout /t 5 /nobreak > nul
        goto WAIT_NPM_INSTALL
    )
)

REM Go back to the main 'Warframe-Algo-Trader' folder
cd /d "%repo_dir%\Warframe-Algo-Trader"

REM Remove the existing config.json file (if it exists)
if exist "config.json" del "config.json"

REM Initialize the tables and create a new config.json file
python init.py

REM Offer platform choice
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

REM Prompt for in-game name
set /p "ign=Enter your in-game name: "

REM Prompt for JWT token
echo.
echo Follow the instructions at https://github.com/NKN1396/warframe.market-api-example to get your JWT token.
set /p "jwt_token=Enter your JWT token (including 'JWT' prefix if present): "

REM Clean JWT token input (remove 'JWT' prefix if present)
set "jwt_token=%jwt_token:JWT =%"

REM Prompt for missing 'JWT' prefix if not provided
if not "%jwt_token:~0,3%"=="JWT" (
    echo JWT prefix is missing. Adding it to the token.
    set "jwt_token=JWT %jwt_token%"
)

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
