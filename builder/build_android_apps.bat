rem 
rem Builds Android applications
rem 

CALL build_java_core.bat

SET FOLDER=../../AndroidStudioProjects/
SET LIST=symphonytimer-android violetnote-android odeon-android fingerlocker-android

FOR %%s IN (%LIST%) DO cmd /c "cd %FOLDER%%%s & gradlew.bat clean build"




