rem 
rem Builds and installs JAVA core libraries
rem 


SET FOLDER=../../
SET LIST=jutils-core violetnote-core

FOR %%s IN (%LIST%) DO cmd /c "cd %FOLDER%%%s & gradlew.bat clean publishToMavenLocal"
