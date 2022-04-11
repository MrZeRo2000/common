rem 
rem Builds JAVA Spring projects
rem 

CALL build_java_core.bat

SET FOLDER=../../
SET LIST=rainments-wss violetnote-wss
SET COMMAND=clean build

CALL internal_build.bat
