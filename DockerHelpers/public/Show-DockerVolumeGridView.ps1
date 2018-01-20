function Show-DockerVolumeGridView
{
    <#
    .SYNOPSIS
    Show docker volumes in a grid; optionally allow items in grid to be 
    selected for input to other commands
    
    .DESCRIPTION
    Show docker volumes in a grid; optionally allow items in grid to be 
    selected for input to other commands
    
    .PARAMETER InputObject
    The docker volumes to show in grid
    
    .PARAMETER Force
    Show grid even when there is only one volume? Only relevant when -PassThru
    supplied
    
    .PARAMETER PassThru
    Pass items selected in grid down the pipeline as input to other commands?
    
    .EXAMPLE
    Show-DockerVolumeGridView
    
    Description
    -----------
    Show all volumes; see `docker volume ls` and `docker volume inspect`
    
    .EXAMPLE
    Show-DockerVolumeGridView -PassThru | Show-DockerVolumeDirectory

    Description
    -----------
    Show directories for the selected volumes

    .NOTES
    Alias 'sdv'

    #>
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject[]] $InputObject,

        [switch]$Force,

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
                Get-DockerVolume
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
            $title = 'docker volume(s)'
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
                    Sort-Object Name -Unique |
                    Select-Object Name, Driver, MountPoint |
                    Out-GridView -Title $title -OutputMode $outputMode
            }

            if ($PassThru)
            {
                $selected | ForEach-Object { Get-DockerVolume ($_.Name) }
            }  
        }
        catch
        {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}

Set-Alias -Name sdv -Value Show-DockerVolumeGridView
Export-ModuleMember -Alias sdv