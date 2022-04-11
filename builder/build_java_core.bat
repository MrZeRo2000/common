rem 
rem Builds and installs JAVA core libraries
rem 

@ECHO OFF

SET FOLDER=../../
SET LIST=jutils-core violetnote-core
SET COMMAND=clean publishToMavenLocal

CALL internal_build.bat
