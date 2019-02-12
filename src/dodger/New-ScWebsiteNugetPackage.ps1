<#
.SYNOPSIS
Generates a NuGet package for a Sitecore Website.

.DESCRIPTION
Generates a NuGet package for Octopus Deploy containing the whole output of a Website.

.PARAMETER WebsiteFolder
The path to the build output of a website.

.PARAMETER PackageName
The name of the package to create.

.PARAMETER Version
The version of the package to generate.

.PARAMETER OutputFolder
The folder where the generated NuGet package will be written.

.PARAMETER NugetCommand
A path to nuget.exe or just "nuget" if NuGet.exe is in the path.

.EXAMPLE
New-ScWebsiteNugetPackage -WebsiteFolder .\website\output -PackageName My.Website -Version 1.2.3 -OutputFolder D:\temp -NugetCommand .\tools\nuget.exe

#>
function New-ScWebsiteNugetPackage
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $WebsiteFolder,
      [Parameter(Mandatory=$true)]
      [string] $PackageName,
      [Parameter(Mandatory=$true)]
      [string] $Version,
      [Parameter(Mandatory=$true)]
      [string] $OutputFolder = ".",
      [string] $NugetCommand = "nuget",
      [string] $Author = "Unic AG",
      [string] $IconUrl = "https://www.unic.com/img/unic-logo.png"
  )
  Process
  {
    $WebsiteFolder = Resolve-Path $WebsiteFolder
    $OutputFolder = Resolve-Path $OutputFolder
    $tempNuspec = "$($env:TEMP)\$([Guid]::NewGuid()).nuspec"
    cp "$PSScriptRoot\Website.Template.nuspec.template" $tempNuspec
    & $nugetCommand "pack" $tempNuspec -p "ID=$PackageName" -p "Folder=$WebsiteFolder" -p "AUTHOR=$Author" -p "ICONURL=$IconUrl" -version $Version -OutputDirectory $OutputFolder 
    rm $tempNuspec
    if($LASTEXITCODE -ne 0) {
        Write-Error "There was an error during creating website package $PackageName from file $ItemsFile."
    }
  }
}
