Describe 'Get-DockerContainerIP' -Tags Build {

    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
        $fakeContainer = [PsCustomObject]@{ Name = 'some-container'}
    }

    AfterAll {
        Unload-SUT
    }

    It 'Alias' {
        & {gdip -EA Stop | Out-Null; $true} | Should -Be $true
    }

    It 'List' {
        & {Get-DockerContainerIP -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It 'List -All' {
        & {Get-DockerContainerIP -All -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It '-All cannot be used with -Name' {
        {Get-DockerContainerIP -All -Name 'some-container' -EA Stop} | Should throw
    }

    It '-Name' {
        & {Get-DockerContainerIP -Name 'some-container' -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It '-Name (by position)' {
        & {Get-DockerContainerIP 'some-container' -EA Stop | Out-Null; $true} | Should -Be $true
    }

    It '-Name cannot be used with -Container' {
        {Get-DockerContainerIP -Name 'some-container' -Container $fakeContainer -EA Stop} | Should throw
    }
    
    It '-Container' {
        & { @($fakeContainer) | Get-DockerContainerIP -EA Stop | Out-Null; $true} | Should -Be $true
    }
}

