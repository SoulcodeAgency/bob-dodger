$PSScriptRoot = split-path -parent $MyInvocation.MyCommand.Definition

$module = "Dodger"

Import-Module "$PSScriptRoot\packages\Unic.Bob.Keith\Keith" -Force
Import-Module "$PSScriptRoot\src\$module" -Force

New-PsDoc -Module $module -Path "$PSScriptRoot\docs\" -OutputLocation "$PSScriptRoot\docs-generated"

if(-not (Test-Path "$PSScriptRoot\temp")) {
    mkdir "$PSScriptRoot\temp"
}

#Copy-Item .\package.json.default "$PSScriptRoot\temp\package.json"

Write-Host "install gitbook"
Push-Location "$PSScriptRoot\temp"
. {$object = npm install gitbook-cli} 2>&1; $object
Pop-Location

Write-Host "new-gitbook"



New-GitBook "$PSScriptRoot\docs-generated" "$PSScriptRoot\temp"
