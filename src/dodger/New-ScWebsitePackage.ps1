<#
.SYNOPSIS
Builds and publishes every Visual Studio project in the repository.

.DESCRIPTION
Builds and publishes every Visual Studio project in the repository.

.PARAMETER MSBuildPath
The path to msbuild.exe

.PARAMETER OutputFolder
The folder where all files should be published to.

.PARAMETER TempPath
A temp path which the build process should use.

.PARAMETER VSVersion
The Visual Studio Version number. Default is 14.0.

.EXAMPLE
New-ScWebsitePackage -MSBuildPath "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" -OutputFolder ./output

#>
function New-ScWebsitePackage
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$MSBuildPath,
        [Parameter(Mandatory=$true)]
        [string]$OutputFolder,
        [string]$TempPath = $env:TEMP,
        [string]$SolutionPath,
        [string]$VSVersion = "14.0"
    )
    Process
    {
        $projects = (ls $ProjectPath -Include *.csproj -Recurse)
        
        $tempPath = "$TempPath\$([guid]::NewGuid().Guid)"
        mkdir $tempPath
        
        $buildPath = "$tempPath\build"
        if(-not (Test-Path $OutputFolder)) {
            mkdir $OutputFolder
        }
        
        
        
        $publishUrl = "D:\temp\foo"
        
        $profilePath = "$tempPath\Test.pubxml"
        
        @"
<?xml version="1.0" encoding="utf-8"?>
<!--
This file is used by the publish/package process of your Web project. You can customize the behavior of this process
by editing this MSBuild file. In order to learn more about this please visit http://go.microsoft.com/fwlink/?LinkID=208121. 
-->
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <WebPublishMethod>FileSystem</WebPublishMethod>
    <LastUsedBuildConfiguration>Release</LastUsedBuildConfiguration>
    <LastUsedPlatform>Any CPU</LastUsedPlatform>
    <SiteUrlToLaunchAfterPublish />
    <LaunchSiteAfterPublish>True</LaunchSiteAfterPublish>
    <ExcludeApp_Data>False</ExcludeApp_Data>
    <publishUrl>$OutputFolder</publishUrl>
    <DeleteExistingFiles>False</DeleteExistingFiles>
  </PropertyGroup>
</Project>
"@ | Out-File $profilePath -Encoding UTF8
        
        if(-not $SolutionPath) {
            $SolutionPath = (Resolve-Path *.sln)
        }
        
        & $MSBuildPath $SolutionPath /p:DeployOnBuild=true /p:VisualStudioVersion=$VSVersion /p:PublishProfile=$profilePath /p:Configuration=Release
        
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error "An error has occured. The solution build process failed."
        }
          
        rm $tempPath -Recurse       
    }
}
