using module "./boost-builder.psm1"


class WinBoostBuilder : BoostBuilder {
    <#
    .SYNOPSIS
    Ubuntu Boost builder class.

    .DESCRIPTION
    Contains methods that required to build Ubuntu Boost artifact from sources. Inherited from base NixBoostBuilder.

    .PARAMETER Toolset
    The toolset which well be used to buil source code on windows vs.

    #>

    [string] $InstallationTemplateName
    [string] $InstallationScriptName
    [string] $OutputArtifactName

    WinBoostBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture,
        [string] $toolset
    ) : Base($version, $platform, $architecture, $toolset) {
        $this.InstallationTemplateName = "win-setup-template.ps1"
        $this.InstallationScriptName = "setup.ps1"
        $toolsetPart = $toolset.Replace("-", "")
        $this.OutputArtifactName = "boost-$Version-$Platform-$toolsetPart-$Architecture.tar.gz"
    }

    [void] CreateIncludeSymlink() {
        $includeFolder = "$($this.WorkFolderLocation)\include"
        $headerDestination = "$($this.WorkFolderLocation)\include\boost"
        if ((Test-Path $includeFolder) -and (-not(Test-Path $headerDestination))) {
            Write-Host "Move headers to root"
            $headersSource = Get-Childitem $includeFolder | Where-Object { $_.PsIsContainer } | Select-Object -First 1 -ExpandProperty FullName
            Copy-Item -Path "${headersSource}\boost" -Destination $headerDestination -Recurse -Container
        }
    
        if (-not (Test-Path -Path "$($this.WorkFolderLocation)\bjam.exe")) {
            Copy-Item -Path "$($this.WorkFolderLocation)\b2.exe" -Destination "$($this.WorkFolderLocation)\bjam.exe"
        }
    }

    [void] Make() {
        Write-Host "Initialize VS dev environment"
        Invoke-VSDevEnvironment

        Push-Location -Path $this.WorkFolderLocation

        Write-Host "Invoke bootstrap.sh"
        Execute-Command "./bootstrap.bat msvc"

        Write-Host "Build boost with '$($this.Toolset)' toolset..."
        $commonArguments = @(
            "install",
            "--prefix='$($this.WorkFolderLocation)'",
            "--build-dir='$($this.TempFolderLocation)'",
            "variant='debug,release'",
            "link='static,shared'",
            "runtime-link='static,shared'",
            "address-model='32,64'",
            "toolset='$($this.Toolset)'",
            "-j4"
        ) -join " "
        Execute-Command "./b2 $commonArguments" -ErrorAction Continue

        $this.CreateIncludeSymlink()

        Pop-Location
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Boost artifact installation script based on specified template.
        #>

        $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName
        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw

        $variablesToReplace = @{
            "{{__VERSION__}}" = $this.Version;
            "{{__ARCHITECTURE__}}" = $this.Architecture;
        }

        $variablesToReplace.keys | ForEach-Object { $installationTemplateContent = $installationTemplateContent.Replace($_, $variablesToReplace[$_]) }
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation
        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }

    [void] ArchiveArtifact() {
        $archiveTempDir = (New-Item -Name "tempArchive" -ItemType Directory -Path $this.TempFolderLocation).Fullname
        $TempTarArchive = [IO.Path]::GetFileNameWithoutExtension($this.OutputArtifactName)
        $OutPathTempTar = Join-Path -Path $archiveTempDir -ChildPath $TempTarArchive
        $OutputPath = Join-Path -Path $this.ArtifactFolderLocation -ChildPath $this.OutputArtifactName
        Write-Host "Pack to tar"
        Create-SevenZipArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutPathTempTar -ArchiveType "tar" -IncludeSymlinks
        Write-Host "Pack to tar.gz"
        Create-SevenZipArchive -SourceFolder $archiveTempDir -ArchivePath $OutputPath -ArchiveType "gzip"
    }
}
