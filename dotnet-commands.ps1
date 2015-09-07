function Set-DotNetEnvironment {
    #Set environment variables for Visual Studio Command Prompt
    pushd 'c:\Program Files (x86)\Microsoft Visual Studio 12.0\VC'

    cmd /c "vcvarsall.bat&set" |
    foreach {
      if ($_ -match "=") {
        $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
      }
    }
    popd
    write-host "dotnet environment variables set (vs2013), msbuild tools path: " -ForegroundColor Yellow -NoNewLine

    $msbuildPathData = reg.exe query "HKLM\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0" /v MSBuildToolsPath
    $script:msbuildPath = (($msbuildpathData[2] -split "\s+")[3]).Trim()
    write-host $msbuildPath -ForegroundColor magenta
}

Set-Alias vs "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"
Set-Alias dotnetsetup Set-DotNetEnvironment

function Echo-DotnetCommands {
    Write-Title "Dotnet commands:"
    write-host "dotnetsetup                   | setup dotnet environment variables and msbuild tools path"
    write-host "vs x                          | open solution x in visual studio"
    write-host "msbuild x                     | run msbuild with args x"
}
