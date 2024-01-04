@ECHO OFF
rem 
rem Builds and installs JAVA core libraries
rem 

CALL set_java_home.bat

SET FOLDER=../../
SET LIST=jutils-core violetnote-core
SET COMMAND=clean publishToMavenLocal

CALL internal_build.bat
