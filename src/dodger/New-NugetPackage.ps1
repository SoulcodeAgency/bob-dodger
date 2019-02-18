<#
.SYNOPSIS
Builds a NuGet package.

.DESCRIPTION
Builds a NuGet package with a specified id and version
from specified folder.

.PARAMETER BaseFolder
The folder containing the content to pack.

.PARAMETER PackageName
The NuGet package id.

.PARAMETER Version
The version of the NuGet package to create.

.PARAMETER OutputFolder
The folder where the generated NuGet package will be written.

.PARAMETER NugetCommand
A path to nuget.exe or just "nuget" if NuGet.exe is in the path.

.PARAMETER Author
The Author of the package to generate. Defaults to "Unic AG".

.PARAMETER IconUrl
The IconUrl to be used for the package. Defaults to Unic AG Icon.

.EXAMPLE
New-NugetPackage -ItemsFolder "./output/" -PackageName "Post.Items" -Version "%GitVersion.NuGetVersionV2%" -OutputFolder "./output" -NugetCommand "%teamcity.tool.NuGet.CommandLine.DEFAULT.nupkg%\tools\nuget.exe"
#>
function New-NugetPackage
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $BaseFolder,
      [Parameter(Mandatory=$true)]
      [string] $PackageName,
      [Parameter(Mandatory=$true)]
      [string] $Version,
      [Parameter(Mandatory=$true)]
      [string] $OutputFolder = ".",
      [string]$NugetCommand = "nuget",
      [string]$Author = "Unic AG",
      [string]$IconUrl = "https://www.unic.com/img/unic-logo.png"
)
  Process
  {
    $BaseFolder = Resolve-Path $BaseFolder
    $OutputFolder = Resolve-Path $OutputFolder
    $tempNuspec = "$($env:TEMP)\$([Guid]::NewGuid()).nuspec"
    cp "$PSScriptRoot\nuspec.template" $tempNuspec
    & $nugetCommand "pack" $tempNuspec -p "ID=$PackageName" -p "AUTHOR=$Author" -p "ICONURL=$IconUrl" -BasePath $BaseFolder -version $Version -OutputDirectory $OutputFolder
    rm $tempNuspec
    if($LASTEXITCODE -ne 0) {
        Write-Error "There was an error during creating items package $PackageName from folder $BaseFolder."
    }
  }
}
