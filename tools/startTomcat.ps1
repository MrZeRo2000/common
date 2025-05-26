$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\..\builder\builder.psm1

$tomcatPath = Find-Tomcat
Write-Host "Tomcat: $tomcatPath" -ForegroundColor DarkGray

If (-Not (Set-Java-Home)) {
    Exit
} 


# Define Java options
$javaOpts = "-Xms512m", "-Xmx1024m"  # Example heap memory settings, adjust as needed

$arguments = @(
    "-Djava.util.logging.config.file=$tomcatPath\conf\logging.properties",
    "-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager",
    "$javaOpts",
    "-classpath `"$tomcatPath\bin\bootstrap.jar;$tomcatPath\bin\tomcat-juli.jar`"",
    "-Dcatalina.base=`"$tomcatPath`"",
    "-Dcatalina.home=`"$tomcatPath`"",
    "-Djava.io.tmpdir=`"$tomcatPath\temp`"",
    "--add-opens=java.base/java.lang=ALL-UNNAMED",
    "--add-opens=java.base/java.io=ALL-UNNAMED",
    "--add-opens=java.base/java.util=ALL-UNNAMED",
    "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED",
    "--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED",
    "org.apache.catalina.startup.Bootstrap", 
    "start"    
)

# $argumentList = "-Djava.util.logging.config.file=$tomcatPath\conf\logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager $javaOpts -classpath `"$tomcatPath\bin\bootstrap.jar;$tomcatPath\bin\tomcat-juli.jar`" -Dcatalina.base=`"$tomcatPath`" -Dcatalina.home=`"$tomcatPath`"  -Djava.io.tmpdir=`"$tomcatPath\temp`" org.apache.catalina.startup.Bootstrap start"

$argumentList = $arguments -join " "

Write-Host "Argument list: $argumentList" -ForegroundColor DarkGray

# Start Tomcat server with Java options
Start-Process -FilePath "$env:JAVA_HOME\bin\java.exe" -ArgumentList $argumentList -NoNewWindow -Wait
