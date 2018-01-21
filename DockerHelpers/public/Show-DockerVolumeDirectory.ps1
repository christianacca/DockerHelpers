function Show-DockerVolumeDirectory
{
    <#
    .SYNOPSIS
    Show the filesystem content of docker volumes
    
    .DESCRIPTION
    Show the filesystem content of docker volumess
    
    .PARAMETER Name
    Filter volume to return based on name
    
    .PARAMETER InputObject
    The docker volumes to show in grid
    
    .PARAMETER Interactive
    Show the directory contents in windows explorer? Defaults to true
    Where Windows explorer is not available, falls back to listing the content
    in the console
    
    .EXAMPLE
    Show-DockerVolumeDirectory

    Description
    -----------
    Show directory content of all volume

    .EXAMPLE
    Show-DockerVolumeDirectory 'my-vol*' -Interactive:$false

    Description
    -----------
    Show directory content of those volumes whose name matches the wildcard search;
    use the console to display this content

    .EXAMPLE
    Show-DockerVolumeGridView -PassThru | Show-DockerVolumeDirectory

    Description
    -----------
    Show directory content for the selected volumes
    
    .NOTES
    Alias 'sdvd'

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Name', Position = 0)]
        [SupportsWildcards()]
        [string[]]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Volume', Position = 0)]
        [PSCustomObject[]]$InputObject,

        [switch] $Interactive
    )
    
    begin
    {
        if (!$PSBoundParameters.ContainsKey('Interactive'))
        {
            $Interactive = $true
        }
        if (-not(Test-Path 'C:\Windows\explorer.exe'))
        {
            $Interactive = $false
        }

        $volumes = @()
        $showDirectory = if ($Interactive)
        {
            { Start-Process explorer $_.Mountpoint }
        }
        else
        {
            { 
                "Volume '$($_.Name)'" | Out-Host
                $directoryContent = Get-ChildItem $_.Mountpoint
                if ($directoryContent)
                {
                    $directoryContent | Out-Host
                } 
                else
                {
                    "$([Environment]::NewLine)" | Out-Host
                    "    Directory: None" | Out-Host
                }
                "$([Environment]::NewLine)" | Out-Host
            }
        }
    }
    
    process
    {
        $volumes += switch ($PSCmdlet.ParameterSetName)
        {
            'Name'
            { 
                Get-DockerVolume -Name $Name
            }
            'Volume'
            {
                $InputObject
            }
            'List'
            {
                Get-DockerVolume
            }
            Default
            {
                throw "ParameterSet '$PSCmdlet.ParameterSetName' not implemented"
            }
        }
    }

    end
    {
        $volumes | Sort-Object Mountpoint -Unique | ForEach-Object $showDirectory
    }
}

Set-Alias -Name sdvd -Value Show-DockerVolumeDirectory
Export-ModuleMember -Alias sdvd