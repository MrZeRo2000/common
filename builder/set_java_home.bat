rem 
rem Finds JAVA HOME and sets environment variable
rem 

@ECHO OFF

FOR %%D IN (%LOCALAPPDATA%\Programs C:\WinApp) DO (
  REM ECHO Outer D=%%D

  IF EXIST %%D (
    REM ECHO Found %%D

    FOR /F "delims=" %%F IN ('DIR %%D /b ^| findstr "jdk"') DO (
      REM ECHO D=%%D, F=%%F
      SET "JAVA_HOME=%%D\%%F"      
      GOTO :found
    )
  )
)
ECHO !!ERROR!! Java home not found
EXIT 1

:found
ECHO Java home found: %JAVA_HOME%
