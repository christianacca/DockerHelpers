Describe 'Get-DockerVolume' -Tags Build {

    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
        $fakeContainer = [PsCustomObject]@{ Name = 'some-vol'}
    }

    AfterAll {
        Unload-SUT
    }

    It 'Alias' {
        & {gdv -EA Stop | Out-Null; $true} | Should -Be $true
    }

    It 'List' {
        & {Get-DockerVolume -EA Stop | Out-Null; $true} | Should -Be $true
    }

    It '-Name' {
        & {Get-DockerVolume -Name 'some-vol' -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It '-Name (by position)' {
        & {Get-DockerVolume 'some-vol' -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It '-Name array' {
        & {Get-DockerVolume 'some-vol1', 'some-vol2' -EA Stop | Out-Null; $true} | Should -Be $true
    }

    It '-Name cannot be used with -Container' {
        {Get-DockerVolume 'some-vol' -Container $fakeContainer -EA Stop} | Should throw
    }
    
    It '-Name cannot be used with -ContainerName' {
        {Get-DockerVolume 'some-vol' -ContainerName 'some-container' -EA Stop} | Should throw
    }

    It '-ContainerName' {
        & {Get-DockerVolume -ContainerName 'some-container' -EA Stop | Out-Null; $true} | Should -Be $true
    }
    
    It '-Container' {
        & { @($fakeContainer) | Get-DockerVolume -EA Stop | Out-Null; $true} | Should -Be $true
    }
}

