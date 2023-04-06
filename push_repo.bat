@echo off
set /p message="Enter the commit message: "
echo.
echo Adding all files...
git add --all
echo.
echo Committing changes...
git commit -m "%message%"
echo.
echo Pushing to remote repository...
git push --set-upstream origin remote
echo.
echo Done.
pause
