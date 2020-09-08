Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")
Import-Module (Join-Path $PSScriptRoot "../helpers/win-vs-env.psm1")

BeforeAll {
    Set-Location -Path "sources"

    $env:Path="$env:Path;${env:BOOST_ROOT}\lib"

    Write-Host "Initialize VS dev environment"
    Invoke-VSDevEnvironment
}

Describe "Windows Tests" {
    It "Run simple code" {
        "cl -nologo /EHsc -I ${env:BOOST_ROOT}\include main.cpp" | Should -ReturnZeroExitCode
        ".\main.exe" | Should -ReturnZeroExitCode
    }

    It "Build with static libraries 1" {
        $buildArguments = @(
            "/EHsc",
            "/I", "${env:BOOST_ROOT}\include",
            "main-headers.cpp",
            "/link", "/LIBPATH:${env:BOOST_ROOT}\lib",
            "/OUT:main_static_lib_1.exe"
        )
        "cl -nologo $buildArguments" | Should -ReturnZeroExitCode
        ".\main_static_lib_1.exe" | Should -ReturnZeroExitCode
    }

    It "Build with dynamic libraries 1" {
        $buildArguments = @(
            "/EHsc", "/MD",
            "/I", "${env:BOOST_ROOT}\include",
            "main-headers.cpp",
            "/link", "/LIBPATH:${env:BOOST_ROOT}\lib",
            "/OUT:main_dynamic_lib_1.exe"
        )
        "cl -nologo $buildArguments" | Should -ReturnZeroExitCode
        ".\main_dynamic_lib_1.exe" | Should -ReturnZeroExitCode
    }

    It "Build with static libraries 2" {
        $buildArguments = @(
            "/EHsc",
            "/I", "${env:BOOST_ROOT}\include",
            "main_log.cpp",
            "/link", "/LIBPATH:${env:BOOST_ROOT}\lib",
            "/OUT:main_static_lib_2.exe"
        )
        "cl -nologo $buildArguments" | Should -ReturnZeroExitCode
        ".\main_static_lib_2.exe" | Should -ReturnZeroExitCode
    }

    It "Build with dynamic libraries 2" {
        $buildArguments = @(
            "/EHsc", "/MD",
            "/I", "${env:BOOST_ROOT}\include",
            "main_log.cpp",
            "/link", "/LIBPATH:${env:BOOST_ROOT}\lib",
            "/OUT:main_dynamic_lib_2.exe"
        )
        "cl -nologo $buildArguments" | Should -ReturnZeroExitCode
        ".\main_dynamic_lib_2.exe" | Should -ReturnZeroExitCode
    }
}