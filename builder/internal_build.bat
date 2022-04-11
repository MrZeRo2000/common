FOR %%s IN (%LIST%) DO (
  @echo ======== Building %%s ===============

  cmd /c "cd %FOLDER%%%s & gradlew.bat %COMMAND%"

  @echo ======== Build %%s success===========

  @if ERRORLEVEL 1 goto error
)

goto ok

:error
echo "ERROR !!!"
echo %ERRORLEVEL%
pause

:ok
@echo ======== Build completed
