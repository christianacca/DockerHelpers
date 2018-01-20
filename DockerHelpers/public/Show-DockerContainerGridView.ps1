function Show-DockerContainerGridView
{
    <#
    .SYNOPSIS
    Show docker containers in a grid; optionally allow items in grid to be selected 
    for input to other commands
    
    .DESCRIPTION
    Show docker containers in a grid; optionally allow items in grid to be selected 
    for input to other commands
    
    .PARAMETER InputObject
    The docker containers to show in grid

    .PARAMETER All
    Include stopped containers?
    
    .PARAMETER Inspect
    Return information about the container using `docker inspect`? 
    Only relevant when -PassThru supplied
    
    .PARAMETER Force
    Show grid even when there is only one container? Only relevant when -PassThru
    supplied
    
    .PARAMETER PassThru
    Pass items selected in grid down the pipeline as input to other commands?
    
    .EXAMPLE
    Show-DockerContainerGridView -All

    Description
    -----------
    Include both running and stopped containers; see `docker container ls`

    .EXAMPLE
    Show-DockerContainerGridView -PassThru -Force | ForEach-Object { docker container rm $_.Name }
    # or
    sdc -PassThrus -Force | % { docker rm $_.Name }

    Description
    -----------
    Show running containers for selection, even if there is only one; run the native docker
    remove command on any container selected from grid

    .EXAMPLE
    Get-DockerContainer 'mycompose_*' | Show-DockerContainerGridView -PassThru | % { docker rm $_.Name }

    Description
    -----------
    Show containers whose name matches the wildcard search to allow user to select which ones 
    to remove
    
    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Input')]
        [PSCustomObject[]] $InputObject,

        [Parameter(ParameterSetName = 'List')]
        [switch] $All,

        [switch] $Inspect,

        [switch] $Force,

        [switch] $PassThru
    )
    
    begin
    {
        Set-StrictMode -Version 'Latest'
        $callerEA = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'

        $items = @()
    }
    
    process
    {
        try
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
        catch
        {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }

    end
    {
        try
        {
            $title = 'docker container(s)'
            if (!$All)
            {
                $title = "RUNNING $title"
            }
            if ($PassThru)
            {
                $title = "Select $title; tip: hold down CTRL button for multi-select"
            }

            $outputMode = if ($PassThru)
            {
                'Multiple'
            }
            else
            {
                'None'
            }

            $selected = if ($PassThru -and !$Force -and $items.Count -eq 1)
            {
                $items
            }
            else
            {
                $items |
                    Sort-Object Name -Unique | Sort-Object Image, Name |
                    Out-GridView -Title $title -OutputMode $outputMode
            }

            if ($PassThru)
            {
                $selected | Select-Object -Exp Name | Get-DockerContainer -Inspect:$Inspect
            }            
        }
        catch
        {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}

Set-Alias -Name sdc -Value Show-DockerContainerGridView
Export-ModuleMember -Alias sdc