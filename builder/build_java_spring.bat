rem 
rem Builds JAVA Spring projects
rem 

SET FOLDER=../../

CALL build_java_core.bat
cmd /c "cd %FOLDER%rainments-wss & gradlew.bat clean build"
cmd /c "cd %FOLDER%violetnote-wss & gradlew.bat clean build"
