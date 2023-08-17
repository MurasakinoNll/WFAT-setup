@echo off
setlocal

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

REM Install Python 3.11
echo Installing Python 3.11...
start /wait "" "https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe" /quiet

REM Activate Python virtual environment
cd "%repo_dir%\Warframe-Algo-Trader"
python -m venv venv
call venv\Scripts\activate

REM Install required Python packages
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

REM Deactivate Python virtual environment
deactivate

REM Restore the previous environment
endlocal
