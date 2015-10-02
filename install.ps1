$installRootDir = "c:\work"
#$installRootDir = "d:\"
$installRootDir = "d:\"
$consoleDir = "C:\Program Files\ConEmu"
$consolePath = "$consoleDir\ConEmu64.exe"
$envDir = "$installRootDir\env"

#local env
mkdir $installRootDir

#git
choco install git -y -params '"/GitAndUnixToolsOnPath"' --force

# Install my fork of git credential store
cd $installRootDir
git clone https://nickmeldrum@git01.codeplex.com/forks/nickmeldrum/gitcredentialstore gitcredentialstore
cd gitcredentialstore
msbuild
.\InstallLocalBuild.cmd

# Get my environment settings and files and set them up
cd $installRootDir
git clone https://nickmeldrum@github.com/nickmeldrum/win-console-environment.git env
cd env
copy .gitconfig ~/.gitconfig
copy localconfig.json ~/localconfig.json

# python
# choco install python2 -y
choco install python2-x86_32 -y

# nodejs
choco install nodejs -y
copy .npmrc ~/.npmrc

# autohotkey
choco install autohotkey -y
copy autohotkey.ahk ~/Documents/autohotkey.ahk

# Setup autohotkey to run and always run on logon
autohotkey
$action = New-ScheduledTaskAction -Execute "C:\Program Files\AutoHotkey\AutoHotkey.exe" -Id "autohotkey"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutoHotkey"

# Setup powershell environment - profile/ posh git etc. not being picked up?
if (test-path $profile) {
	del $profile -force
}
new-item $profile -force -type file
copy copy-of-profile.ps1 $profile -force
cd 3rdparty
git clone https://github.com/dahlbyk/posh-git.git
cd ..

# Setup vim
ren "C:\Program Files\Git\usr\bin\vim.exe" "C:\Program Files\Git\usr\bin\vim.exe.bak"
choco install vim -y --force
copy .vimrc ~/.vimrc
mkdir ~/.vim/bundle
cd ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git
vim +PluginInstall +qall


# Setup conemu
choco install conemu -y
# import conemu settings
# create cmd/ vim/ scribestar and npm shortcuts with icons on the taskbar

# Setup sublime text license
choco install sublimetext2 -y

# Setup diff tool

# 3rd party application installs
choco install passwordsafe -y
choco install dropbox -y

function recreate-shortcut-and-pin-it {
    param ([string]$Source, [string]$Arguments, [string]$WorkingDir, [string]$IconPath, [string]$Destination, [string]$Hotkey, [string]$Description)

    if (test-path($Destination)) {del $Destination -force}

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Destination)
    $Shortcut.TargetPath = $Source
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = $WorkingDir
    $Shortcut.IconLocation = $IconPath
    $Shortcut.WindowStyle = 3
    $Shortcut.Hotkey = $Hotkey
    $Shortcut.Description = $Description
    $Shortcut.Save()

    $destinationFilename = [System.IO.Path]::GetFileName($Destination)
    $destinationPath = [System.IO.Path]::GetDirectoryName($Destination)

    $shell = new-object -com "Shell.Application"  
    $folder = $shell.Namespace($destinationPath)    
    $item = $folder.Parsename($destinationFilename)

    $pn = $shell.namespace($destinationPath).parsename($destinationFilename)
    $pn.invokeverb('taskbarunpin')
    $pn.invokeverb('taskbarpin')
}

recreate-shortcut-and-pin-it -Source $consolePath -Arguments "/cmd {vim}" `
                -WorkingDir $consoleDir -IconPath "$envDir\vim.ico" `
                -Destination "$envDir\vim.lnk" -Hotkey "CTRL+ALT+V" -Description "Vim in conemu"

recreate-shortcut-and-pin-it -Source $consolePath -Arguments "/cmd {cmd}" `
                -WorkingDir $consoleDir -IconPath "$envDir\cmd.ico" `
                -Destination "$envDir\vim.lnk" -Hotkey "CTRL+ALT+C" -Description "Powershell in conemu"

recreate-shortcut-and-pin-it -Source $consolePath -Arguments "/cmd {scribestar}" `
                -WorkingDir $consoleDir -IconPath "$envDir\scribestar.ico" `
                -Destination "$envDir\vim.lnk" -Hotkey "CTRL+ALT+S" -Description "Scribestar env in conemu"

recreate-shortcut-and-pin-it -Source $consolePath -Arguments "/cmd {npmapp}" `
                -WorkingDir "$installRootDir\nickmeldrum" -IconPath "$envDir\npm.ico" `
                -Destination "$envDir\vim.lnk" -Hotkey "CTRL+ALT+N" -Description "npm env in conemu"

