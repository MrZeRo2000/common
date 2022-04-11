rem 
rem Builds and installs Android libraries
rem 

CALL build_java_core.bat

SET FOLDER=../../AndroidStudioProjects/
SET LIST=library-common-android library-dropbox-android library-gdrive-android library-msgraph-android library-view-android
SET COMMAND=clean publishToMavenLocal

CALL internal_build.bat
