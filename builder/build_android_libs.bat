rem 
rem Builds and installs Android libraries
rem 

CALL build_java_core.bat

SET FOLDER=../../AndroidStudioProjects/
SET LIST=library-dropbox-android library-gdrive-android library-msgraph-android library-view-android

FOR %%s IN (%LIST%) DO cmd /c "cd %FOLDER%%%s & gradlew.bat clean publishToMavenLocal"




