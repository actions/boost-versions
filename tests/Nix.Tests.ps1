Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

BeforeAll {
    Set-Location "sources"
    $env:Path="$env:Path;${env:BOOST_ROOT}\lib"
    if (${env:PLATFORM} -eq "linux-16.04") {
        Write-Host "Install dependencies"
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 `
            --slave /usr/bin/g++ g++ /usr/bin/g++-7 
        sudo update-alternatives --config gcc
}

}

Describe "Nix Tests" {
    

    It "Simple code" {
        "g++ -w -I ${env:BOOST_ROOT}/include main.cpp -o headers_test" | Should -ReturnZeroExitCode
        "./headers_test" | Should -ReturnZeroExitCode
    }

    It "Test header existence" {
        "g++ -w -std=c++14 -I ${env:BOOST_ROOT}/include main-headers.cpp -o headers_test_2" | Should -ReturnZeroExitCode
        "./headers_test_2" | Should -ReturnZeroExitCode
    }

    It "Test shared debug" {
        $BuildParams = (
            "-w", "-DBOOST_LOG_DYN_LINK",
            "-I", "${env:BOOST_ROOT}/include",
            "-L", "${env:BOOST_ROOT}/lib", "main_log.cpp",
            "-l:libboost_log_setup-mt-d-x64.so.${env:VERSION}",
            "-l:libboost_log-mt-d-x64.so.${env:VERSION}",
            "-l:libboost_thread-mt-d-x64.so.${env:VERSION}",
            "-l:libboost_filesystem-mt-d-x64.so.${env:VERSION}",
            "-lpthread"
        )

        "g++ $BuildParams -o test_shared_debug" | Should -ReturnZeroExitCode
        "./test_shared_debug" | Should -ReturnZeroExitCode
    }

    It "Test shared release" {
        $BuildParams = (
            "-w", "-DBOOST_LOG_DYN_LINK",
            "-I", "${env:BOOST_ROOT}/include",
            "-L", "${env:BOOST_ROOT}/lib", "main_log.cpp",
            "-l:libboost_log_setup-mt-x64.so.${env:VERSION}",
            "-l:libboost_log-mt-x64.so.${env:VERSION}",
            "-l:libboost_thread-mt-x64.so.${env:VERSION}",
            "-l:libboost_filesystem-mt-x64.so.${env:VERSION}", 
            "-lpthread"
        )

        "g++ $BuildParams -o test_shared_release" | Should -ReturnZeroExitCode
        "./test_shared_release" | Should -ReturnZeroExitCode
    }
}