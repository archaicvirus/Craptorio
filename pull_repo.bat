@echo off
echo Fetching changes from the remote repository...
git fetch origin remote
echo.
echo Resetting to the latest remote state...
git reset --hard origin/remote
echo.
echo Done.
pause