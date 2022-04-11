rem 
rem Builds Android applications
rem 

CALL build_android_libs.bat

SET FOLDER=../../AndroidStudioProjects/
SET LIST=symphonytimer-android violetnote-android odeon-android fingerlocker-android
SET COMMAND=clean build

CALL internal_build.bat



