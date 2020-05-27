using module "./builders/boost-builder.psm1"

class NixBoostBuilder : BoostBuilder {
    <#
    .SYNOPSIS
    Ubuntu Boost builder class.

    .DESCRIPTION
    Contains methods that required to build Ubuntu Boost artifact from sources. Inherited from base BoostBuilder.

    #>

    [string] $InstallationTemplateName
    [string] $InstallationScriptName
    [string] $OutputArtifactName

    NixBoostBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture,
        [string] $toolset
    ) : Base($version, $platform, $architecture, $toolset) {
        $this.InstallationTemplateName = "nix-setup-template.sh"
        $this.InstallationScriptName = "setup.sh"
        $this.OutputArtifactName = "boost-$Version-$Platform-$Toolset-$Architecture.tar.gz"
    }

    [void] Make() {
        Push-Location -Path $this.WorkFolderLocation

        Write-Host "Invoke bootstrap.sh"
        Execute-Command "sudo ./bootstrap.sh"

        $commonArguments = @(
            "install"
            "--prefix=$($this.WorkFolderLocation)",
            "--build-dir=$($this.TempFolderLocation)",
            "--layout='tagged'",
            "link='static,shared'",
            "runtime-link='static,shared'"
        ) -join " "

        Write-Host "Build boost static and shared binaries in release"
        Execute-Command "sudo ./b2 $commonArguments variant='release'"

        Write-Host "Build boost static and shared binaries in debug"
        Execute-Command "sudo ./b2 $commonArguments variant='debug'"

        Pop-Location
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Boost artifact installation script based on template specified in InstallationTemplateName property.
        #>

        $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName

        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw
        $variablesToReplace = @{
            "{{__VERSION__}}" = $this.Version;
            "{{__ARCHITECTURE__}}" = "x64";
        }

        $variablesToReplace.keys | ForEach-Object { $installationTemplateContent = $installationTemplateContent.Replace($_, $variablesToReplace[$_]) }
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation

        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }

    [void] ArchiveArtifact() {
        $OutputPath = Join-Path $this.ArtifactFolderLocation $this.OutputArtifactName
        Create-TarArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutputPath
    }
}