function Wait-DockerContainerStatus
{
    <#
    .SYNOPSIS
    Waits for the container status supplied
    
    .DESCRIPTION
    Waits for the container status supplied
    
    .PARAMETER Name
    The container to inspect
    
    .PARAMETER Status
    The status to wait for
    
    .PARAMETER Timeout
    The time (in seconds) to wait until giving up and throwing
    
    .PARAMETER Interval
    The polling interval to check for container status
    
    .EXAMPLE
    Wait-DockerContainerStatus 'some-container' running

    Description
    -----------
    Wait for the container named 'some-container' to have a status of running
    
    .NOTES
    Alias 'wdcs'

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('created', 'running', 'paused', 'exited', 'dead', 'healthy', 'unhealthy')]
        [string[]] $Status,

        [int] $Timeout = 90,

        [int] $Interval = 3

    )
    
    begin
    {
        # todo: support wildcards; will need careful thought:
        # * wait for any container with the required status or all containers whose
        #   name matches at the start of the wait?
        # * should created status be treated differently from other status?
        if ($Name -match '\*') {
            throw "Name parameter does not support wildcards"
        }

        $timeToWait = if ($Timeout -eq 0) {
            # ie never timeout!
            (Get-Date).AddYears(99)
        } else {
            (Get-Date).AddSeconds($Timeout)
        }

        $healthStates = 'healthy', 'unhealthy'
        $healthStatus = $Status | Where-Object { $healthStates -contains $_ }

        $getContainerStatusString = {
            $result = "{0}:{1}" -f $_.Name, $_.Status
            if ($_.Health) {
                $result = '{0} ({1})' -f $result, $_.Health
            }
            $result
        }
    }
    
    process
    {
        $names = @()
        $names += $Name | Select-Object -Unique

        while ($true) {
            $container = @(Get-DockerContainerStatus $Name)
            $container | ForEach-Object $getContainerStatusString | Write-Verbose
            $matching = @($container | Where-Object  { $_.Status -in $Status -or $_.Health -in $healthStatus } )
            if ($names.Count -eq $matching.Count) {
                break
            } elseif ((Get-Date) -ge $timeToWait) {
                throw "Timeout exceeded waiting on container (desired status: $Status)"
            } elseif ('healthy' -eq $Status -and ($container | Where-Object Health -eq unhealthy)) {
                throw "Waited status not achievable (desired 'healthy')"
            }
            Start-Sleep -Seconds $Interval
        }
    }
}

Set-Alias -Name wdcs -Value Wait-DockerContainerStatus
Export-ModuleMember -Alias wdcs