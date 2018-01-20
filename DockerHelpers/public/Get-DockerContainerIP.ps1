function Get-DockerContainerIP
{
    <#
    .SYNOPSIS
    Return the IP address assigned to a container
    
    .DESCRIPTION
    Return the IP address assigned to a container
    
    .PARAMETER Name
    Filter container based on name
    
    .PARAMETER All
    Include stopped containers?
    
    .PARAMETER InputObject
    The container object whose IP address to return
    
    .EXAMPLE
    Get-DockerContainerIP

    Name                  IPAddress
    ----                  ---------
    web-spa               172.24.221.65
    web-tokensvr          172.24.221.66

    Description
    -----------
    Return IP address of all running containers; see `docker container ls`
    and `docker container inspect -f`

    .EXAMPLE
    Show-DockerContainerGridView -PassThru | Get-DockerContainerIP
    # or
    sdc -PassThru | gdip

    Description
    -----------
    Return IP address for container(s) selected interactively from a grid
    
    .NOTES
    Alias 'gdip'

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Name', Position=0)]
        [SupportsWildcards()]
        [string[]]$Name,

        [Parameter(ParameterSetName = 'List')]
        [switch] $All,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Container')]
        [PSCustomObject]$InputObject
    )
    
    begin
    {
        Set-StrictMode -Version 'Latest'
        $callerEA = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    
    process
    {
        try
        {
            $containers = switch ($PSCmdlet.ParameterSetName)
            {
                'Name' { Get-DockerContainer -Name $Name -Inspect }
                'List' { Get-DockerContainer -Inspect }
                'Container' {
                    if ($InputObject.PsObject.Properties.Name -notcontains 'NetworkSettings') {
                        Get-DockerContainer -Name ($InputObject.Name) -Inspect
                    } else {
                        $InputObject
                    }
                }
                Default { throw "ParameterSet '$PSCmdlet.ParameterSetName' not implemented"}
            }

            $containers | Select-Object -PV container |
                Select-Object -Exp NetworkSettings | 
                Select-Object -Exp Networks | 
                Select-Object -Exp * |
                Select-Object @{n = 'Name'; e = {$container.Name}}, IPAddress

        }
        catch
        {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}

Set-Alias -Name gdip -Value Get-DockerContainerIP
Export-ModuleMember -Alias gdip