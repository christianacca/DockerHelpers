function Get-DockerContainerStatus
{
    <#
    .SYNOPSIS
    Return the status of a container
    
    .DESCRIPTION
    Return the status of a container
    
    .PARAMETER Name
    Filter container based on name
    
    .PARAMETER All
    Include stopped containers?
    
    .PARAMETER InputObject
    The container object whose status to return
    
    .EXAMPLE
    Get-DockerContainerStatus

    Name                  Status           Health
    ----                  ---------        ---------
    web-spa               running          healthy
    web-tokensvr          running          healthy

    Description
    -----------
    Return status of all running containers

    .EXAMPLE
    Show-DockerContainerGridView -PassThru | Get-DockerContainerStatus
    # or
    sdc -PassThru | gdip

    Description
    -----------
    Return status for container(s) selected interactively from a grid
    
    .NOTES
    Alias 'gdcs'

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Name', Position = 0)]
        [SupportsWildcards()]
        [string[]]$Name,

        [Parameter(ParameterSetName = 'List')]
        [switch] $All,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Container')]
        [PSCustomObject]$InputObject
    )
    
    process
    {
        $containers = switch ($PSCmdlet.ParameterSetName)
        {
            'Name' { Get-DockerContainer -Name $Name -Inspect }
            'List' { Get-DockerContainer -Inspect }
            'Container'
            {
                if ($InputObject.PsObject.Properties.Name -notcontains 'NetworkSettings')
                {
                    Get-DockerContainer -Name ($InputObject.Name) -Inspect
                }
                else
                {
                    $InputObject
                }
            }
            Default { throw "ParameterSet '$PSCmdlet.ParameterSetName' not implemented"}
        }

        $containers | Select-Object `
            @{n = 'Name'; e = {$_.Name}}, 
            @{n = 'Status'; e = { $_.State.Status }},
            @{n = 'Health'; e = { if ($_.State.Health) { $_.State.Health.Status } else { '' } }}
    }
}

Set-Alias -Name gdcs -Value Get-DockerContainerIP
Export-ModuleMember -Alias gdcs