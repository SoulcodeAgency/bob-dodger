<#
.SYNOPSIS
Builds the NuGet package containing all serialization files.

.DESCRIPTION
Builds the NuGet package containing all serialization files.

.PARAMETER Source
Path to the root of the repository.

.PARAMETER PackageName
The name of the package to create.

.PARAMETER Version
The version of the package to generate.

.PARAMETER OutputFolder
The folder where the generated NuGet package will be written.

.PARAMETER NugetCommand
A path to nuget.exe or just "nuget" if NuGet.exe is in the path.

.PARAMETER DistributedSerialization
If DistributedSerialization is true, the command will search for serialization folders in the whole solution.
The excepted structure is as follow: 
 
 ...
   |- serialization
      |- ...
   |- code 
      |- *.csproj
      |- ...
      
If DistributedSerialization is false it will simply take $Source/serialization as the only serialization folder.

.EXAMPLE
New-ConfigNugetPackage -Source D:\projects\myProject -PackageName My.Config -Version 1.2.3 -OutputFolder D:\temp -NugetCommand .\tools\nuget.exe -DistributedSerialization $true
#>
Function New-ScSerializationNugetPackage
{
    [CmdletBinding(
    	SupportsShouldProcess=$True,
        ConfirmImpact="Low"
    )]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        [Parameter(Mandatory=$true)]
        [string]$Version,
        [Parameter(Mandatory=$true)]
        [string]$OutputFolder,
        [Parameter(Mandatory=$true)]
        [string]$NugetCommand,
        [bool]$DistributedSerialization = $true,
        [string]$Author = "Unic AG",
        [string]$IconUrl = "https://www.unic.com/img/unic-logo.png"        
	)
    Begin{}

    Process
    {
        $tempFolder = "$($env:TEMP)\$([Guid]::NewGuid())"
        mkdir $tempFolder | Out-Null
        
        $config = Get-ScProjectConfig $Source
        $basePath = Join-Path $Source $config.SerializationPath
        
        if($DistributedSerialization) {
            $projects = (ls $Source -Include *.csproj -Recurse)
            foreach($project in $projects) {
                $projectPath = Split-Path (Split-Path $project)
                $projectSerialization = "$projectPath\serialization"
                if(Test-Path $projectSerialization) {
                    Write-Host "Add $projectSerialization to $tempFolder\app.zip "
                    Add-RubbleArchiveFile -Path $projectSerialization  -ArchivePath "$tempFolder\app.zip" -RelativeToPath $basePath            
                }
                else {
                    Write-Host "$projectSerialization doesn't exist. Skip."
                }
            }
            
        }
        
        $globalAppSerialization = "$Source\serialization\app\"
        if(Test-Path $globalAppSerialization) {
            Write-Host "Add $globalAppSerialization to $tempFolder\app.zip "
            Add-RubbleArchiveFile -Path $globalAppSerialization -ArchivePath "$tempFolder\app.zip" -RelativeToPath $basePath
        }
        
        $modulesSerializationPath = "$Source\serialization\modules\"    
        if(Test-Path $modulesSerializationPath) {
            Write-Host "Add $modulesSerializationPath to $tempFolder\app.zip "
            Add-RubbleArchiveFile -Path $modulesSerializationPath -ArchivePath "$tempFolder\app.zip" -RelativeToPath $basePath
        }
        
        $rolesSerializationPath = "$Source\serialization\roles\"    
        if(Test-Path $rolesSerializationPath) {
            Write-Host "Add $rolesSerializationPath to $tempFolder\app.zip "
            Add-RubbleArchiveFile -Path $rolesSerializationPath -ArchivePath "$tempFolder\app.zip" -RelativeToPath $basePath
        }

        $appDefaultSerializationPath = "$Source\serialization\appDefault"
        if(Test-Path $appDefaultSerializationPath) {
            Write-Host "Add $appDefaultSerializationPath to $tempFolder\appDefault.zip "
            Add-RubbleArchiveFile -Path $appDefaultSerializationPath -ArchivePath "$tempFolder\appDefault.zip"
        }
        
        New-NugetPackage `
        -BaseFolder $tempFolder `
        -PackageName $PackageName `
        -Version $Version `
        -OutputFolder $OutputFolder `
        -NugetCommand $NugetCommand `
        -Author $Author `
        -IconUrl $IconUrl
        
        rm $tempFolder -Recurse
    }
}
