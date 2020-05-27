using module "./builders/win-boost-builder.psm1"
using module "./builders/nix-boost-builder.psm1"

<#
.SYNOPSIS
Generate Boost artifact.

.DESCRIPTION
Main script that creates instance of BoostBuilder and builds of Boost using specified parameters.

.PARAMETER Version
Required parameter. The version with which Boost will be built.

.PARAMETER Architecture
Optional parameter. The architecture with which Boost will be built. Using x64 by default.

.PARAMETER Platform
Required parameter. The platform for which Boost will be built.

#>

param(
    [Parameter (Mandatory=$true)][Version] $Version,
    [Parameter (Mandatory=$true)][string] $Platform,
    [Parameter (Mandatory=$true)][string] $Architecture,
    [Parameter (Mandatory=$true)][string] $Toolset
)

Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "common-helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "nix-helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "win-helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "win-vs-env.psm1") -DisableNameChecking

$ErrorActionPreference = "Stop"

function Get-BoostBuilder {
    <#
    .SYNOPSIS
    Wrapper for class constructor to simplify importing BoostBuilder.

    .DESCRIPTION
    Create instance of BoostBuilder with specified parameters.

    .PARAMETER Version
    The version with which Boost will be built.

    .PARAMETER Platform
    The platform for which Boost will be built.

    .PARAMETER Architecture
    The architecture with which Boost will be built.

    #>

    param (
        [version] $Version,
        [string] $Architecture,
        [string] $Platform
    )

    if ($Platform -match 'win32') {
        $builder = [WinBoostBuilder]::New($Version, $Platform, $Architecture, $Toolset)
    } elseif ($Platform -match 'linux') {
        $builder = [NixBoostBuilder]::New($Version, $Platform, $Architecture, $Toolset)
    } else {
        Write-Host "##vso[task.logissue type=error;] Invalid platform: $Platform"
        exit 1
    }

    return $builder
}

### Create Boost builder instance, and build artifact
$Builder = Get-BoostBuilder -Version $Version -Platform $Platform -Architecture $Architecture
$Builder.Build()
