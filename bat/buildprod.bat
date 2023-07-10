CALL %CD%/termsetup.bat
RMDIR /S /Q dist\%1
ng build --configuration production --base-href=/%1/
