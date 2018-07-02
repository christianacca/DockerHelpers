$ErrorActionPreference = 'Stop'

Describe 'Wait-DockerContainerStatus' -Tags Build {

    function RemoveContainers {
        Get-DockerContainer some-container, other-container | Select-Object -Exp Name | ForEach-Object {
            docker container rm -f $_
        }
    }

    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)

        # given
        docker pull microsoft/nanoserver
    }

    AfterAll {
        Unload-SUT
    }

    AfterEach { RemoveContainers }
    BeforeEach { RemoveContainers }

    It 'Alias' {
        Get-Alias wdcs | Should -Not -BeNullOrEmpty
    }
    
    It "Wait for 'created'" {
        # given
        docker create --name some-container microsoft/nanoserver

        # when
        Wait-DockerContainerStatus -Name some-container -Status created

        # then
        (Get-DockerContainer some-container -Inspect).State.Status | Should -Be 'created'
    }

    It "Wait for 'exited' (by position)" {
        # given
        docker run -d --name some-container microsoft/nanoserver ping localhost -t
        $stopJob = Start-Job {
            docker stop some-container other-container
        }

        try {
            # when
            Wait-DockerContainerStatus some-container -Status exited

            # then
            (Get-DockerContainer some-container -Inspect).State.Status | Should -Be 'exited'
        }
        finally {
            $stopJob | Wait-Job
        }
    }
    
    It 'Waiting for more than one status... should return when any status found' {
        # given
        $runContainer = Start-Job {
            docker run -d --name some-container microsoft/nanoserver ping localhost -t
        }

        try {
            # when
            Wait-DockerContainerStatus some-container -Status created, running

            # then
            (Get-DockerContainer some-container -Inspect).State.Status | Should -BeIn 'created', 'running'
        }
        finally {
            $runContainer | Wait-Job
        }
    }
    
    It '-Name array' {
        # given
        docker run -d --name some-container microsoft/nanoserver ping localhost -t
        docker run -d --name other-container microsoft/nanoserver ping localhost -t
        $stopJob = Start-Job {
            docker stop some-container other-container
        }

        try {
            # when
            Wait-DockerContainerStatus some-container, other-container -Status exited

            # then
            (Get-DockerContainer some-container -Inspect).State.Status | Should -Be 'exited'
        }
        finally {
            $stopJob | Wait-Job
        }
    }

    It '-Timeout will throw when exceeded' {
        # given
        docker run -d --name some-container microsoft/nanoserver ping localhost -t
        $before = Get-Date

        # when
        [System.Management.Automation.ErrorRecord] $ex = $null
        try {
            Wait-DockerContainerStatus some-container exited -Timeout 1 -EA Stop -Verbose
        }
        catch {
            $ex = $_
        }

        
        # then...
        # note: docker commands take sooooo long on my w10 PC therefore need to use large tolarance (ie 8 seconds)
        ($before).AddSeconds(8) | Should -BeGreaterThan (Get-Date)
        $ex.ToString() | Should -BeLike 'Timeout exceeded*'
    }
    
    It '-Name with wildcard should throw' {
        # given
        docker run -d --name some-container microsoft/nanoserver ping localhost -t

        # when, then...
        { Wait-DockerContainerStatus some-container* exited } | Should throw
    }

    It "Wait for 'healthy'" {
        # given
        docker run -d --name some-container `
            --health-cmd 'cmd /S /C exit 0' --health-interval 5s --health-start-period 10s `
            microsoft/nanoserver ping localhost -t

        # when
        Wait-DockerContainerStatus some-container healthy -Verbose

        # then
        (Get-DockerContainer some-container -Inspect).State.Health.Status | Should -Be 'healthy'
    }
    
    It "Wait for 'unhealthy'" {
        # given
        docker run -d --name some-container `
            --health-cmd 'cmd /S /C exit 1' --health-interval 1s --health-start-period 1s `
            microsoft/nanoserver ping localhost -t

        # when
        Wait-DockerContainerStatus some-container unhealthy -Verbose

        # then
        (Get-DockerContainer some-container -Inspect).State.Health.Status | Should -Be 'unhealthy'
    }
    
    It "Wait for 'unhealthy' or 'healthy'" {
        # given
        docker run -d --name some-container `
            --health-cmd 'cmd /S /C exit 1' --health-interval 1s --health-start-period 1s `
            microsoft/nanoserver ping localhost -t

        # when
        Wait-DockerContainerStatus some-container healthy, unhealthy -Verbose

        # then
        (Get-DockerContainer some-container -Inspect).State.Health.Status | Should -Be 'unhealthy'
    }
}