function Show-DockerContainerVolumeGridView
{
    <#
    .SYNOPSIS
    Select docker containers whose associated volumn are shown in a grid; 
    optionally allow volumes in grid to be selected for input to other commands
    
    .DESCRIPTION
    Select docker containers whose associated volumn are shown in a grid; 
    optionally allow volumes in grid to be selected for input to other commands
    
    .PARAMETER InputObject
    The docker containers to show in grid
    
    .PARAMETER All
    Include stopped containers?
    
    .PARAMETER Force
    Show grid even when there is only one volume? Only relevant when -PassThru
    supplied
    
    .PARAMETER PassThru
    Pass volumes selected in grid down the pipeline as input to other commands?
    
    .EXAMPLE
    Show-DockerContainerVolumeGridView -All

    Description
    -----------
    Select from both running and stopped containers whose volumes are to be shown;
    see `docker container ls` and `docker volume ls`

    .EXAMPLE
    Get-DockerContainer 'mycompose_*' | Show-DockerContainerVolumeGridView

    Description
    -----------
    Select from containers whose name matches the wildcard search; show volumes
    associated with only these containers

    .EXAMPLE
    Show-DockerContainerVolumeGridView -PassThru | Show-DockerVolumeDirectory

    Description
    -----------
    Select from both running containers, then select from volumes associated with
    these containers; show the filesystem contents of the host directory for the
    selected volumes
    
    .NOTES
    Alias sdcv
    
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Input')]
        [PSCustomObject[]] $InputObject,

        [Parameter(ParameterSetName = 'List')]
        [switch] $All,

        [switch] $Force,

        [switch] $PassThru
    )
    
    begin
    {
        $items = @()
    }
    
    process
    {
        $items += if ($InputObject)
        {
            $InputObject
        }
        else
        {
            Get-DockerContainer -All:$All
        }
    }
    end
    {
        $items | Show-DockerContainerGridView -Force -PassThru |
            Get-DockerVolume | 
            Show-DockerVolumeGridView -Force:$Force -PassThru:$PassThru
    }
}

Set-Alias -Name sdcv -Value Show-DockerContainerVolumeGridView
Export-ModuleMember -Alias sdcv