<#
.SYNOPSIS
Builds the NuGet package containing all config files.

.DESCRIPTION
Builds the NuGet package containing all config files.

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

.PARAMETER Author
The Author of the package to generate. Defaults to "Unic AG".

.PARAMETER IconUrl
The IconUrl to be used for the package. Defaults to Unic AG Icon.

.EXAMPLE
New-ConfigNugetPackage -Source D:\projects\myProject -PackageName My.Config -Version 1.2.3 -OutputFolder D:\temp -NugetCommand .\tools\nuget.exe
#>
Function New-ConfigNugetPackage
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
        [string]$NugetCommand = "nuget",
        [string]$Author = "Unic AG",
        [string]$IconUrl = "https://www.unic.com/img/unic-logo.png"
          
	)
    Process
    {
        $tempFolder = "$($env:TEMP)\$([Guid]::NewGuid())"
        mkdir $tempFolder | Out-Null
        
        $config = Get-ScProjectConfig $Source
        $basePath = Join-Path $Source $config.SerializationPath
        
        $projects = (ls $ProjectPath -Include *.csproj -Recurse)
        foreach($project in $projects) {
            $folder = Split-Path $project
            $name = [System.IO.Path]::GetFileNameWithoutExtension((Get-Item $project).Name)
            
            $configFolder = "$tempFolder\$name" 
            if(-not (Test-Path $configFolder)) {
                mkdir $configFolder  
            } 
            cp $folder\Web.*.config $configFolder
        }
        
        cp "$($config.WebsitePath)\Bob.config" $tempFolder
        
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
