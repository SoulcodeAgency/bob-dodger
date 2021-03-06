$ErrorActionPreference = "Stop"

function ResolvePath() {
  param($PackageId, $RelativePath)
  $paths = @("$PSScriptRoot\..\..\tools", "$PSScriptRoot\..\tools", "$PSScriptRoot\..\..\packages")
  foreach($packPath in $paths) {
    $path = Join-Path $packPath "$PackageId\$RelativePath"
    if((Test-Path $packPath) -and (Test-Path $path)) {
      Resolve-Path $path
      return
    }
  }
  Write-Error "No path found for $RelativePath in package $PackageId"
}

Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude "*.Tests.ps1" | Foreach-Object{ . $_.FullName }
Export-ModuleMember -Function * -Alias *

Import-Module (ResolvePath "Unic.Bob.Wendy" "tools\Wendy")
Import-Module (ResolvePath "Unic.Bob.Rubble" "tools\Rubble")
Import-Module (ResolvePath "Unic.Bob.Skip" "Skip")
