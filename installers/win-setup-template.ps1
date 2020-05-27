$ErrorActionPreference = "Stop"

[Version]$Version = "{{__VERSION__}}"
[string]$Architecture = "{{__ARCHITECTURE__}}"

$ToolcacheRoot = $env:AGENT_TOOLSDIRECTORY
if ([string]::IsNullOrEmpty($ToolcacheRoot)) {
    # GitHub images don't have `AGENT_TOOLSDIRECTORY` variable
    $ToolcacheRoot = $env:RUNNER_TOOL_CACHE
}
$BoostToolcachePath = Join-Path -Path $ToolcacheRoot -ChildPath "boost"
$BoostToolcacheVersionPath = Join-Path -Path $BoostToolcachePath -ChildPath $Version.ToString()
$BoostToolcacheArchitecturePath = Join-Path $BoostToolcacheVersionPath $Architecture

Write-Host "Check if Boost hostedtoolcache folder exist..."
if (-not (Test-Path $BoostToolcachePath)) {
    New-Item -ItemType Directory -Path $BoostToolcachePath | Out-Null
}

if (Test-Path $BoostToolcacheArchitecturePath) {
    Write-Host "Delete existing Boost $Version [$Architecture]"
    Remove-Item $BoostToolcacheArchitecturePath -Recurse -Force | Out-Null
}

Write-Host "Create Boost $Version [$Architecture] folder"
New-Item -ItemType Directory -Path $BoostToolcacheArchitecturePath | Out-Null

Write-Host "Copy Boost binaries to hostedtoolcache folder"
Copy-Item -Path * -Destination $BoostToolcacheArchitecturePath -Recurse
Remove-Item $BoostToolcacheArchitecturePath\setup.ps1 -Force | Out-Null

Write-Host "Create complete file"
New-Item -ItemType File -Path $BoostToolcacheVersionPath -Name "$Architecture.complete" | Out-Null