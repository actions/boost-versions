Describe "Common Tests" {
    $BOOST_HEADERS = Join-Path -Path ${env:BOOST_ROOT} -ChildPath "boost"

    It "Check that symlinks points to existing files" {
        Get-ChildItem $BOOST_HEADERS -File -Recurse | Where-Object { $_.Target } | ForEach-Object {
            $_.Target | Should -Exist
        }
    }
    
    It "Check if there is no invalid symlinks" {
        Get-ChildItem $BOOST_HEADERS -Recurse -File | ForEach-Object { 
            Get-Content $_.FullName -Raw | Should -Not -BeNullOrEmpty
        }
    }
}
