function Get-DockerVolume
{
    <#
    .SYNOPSIS
    Return powershell object describing docker volume(s)
    
    .DESCRIPTION
    Return powershell object describing docker volume(s)
    
    .PARAMETER Name
    Filter volume to return based on name
    
    .PARAMETER ContainerName
    Filter volume to those associated with the supplied container
    
    .PARAMETER Container
    Filter volume to those associated with the supplied container
    
    .EXAMPLE
    Get-DockerVolume

    Description
    -----------
    Return all volumes; see `docker volume ls` and `docker volume inspect`
    
    .EXAMPLE
    Get-DockerVolume my-vol1, my-vol2

    Description
    -----------
    Return multiple volumes by exact name match

    .EXAMPLE
    Get-DockerVolume 'my-*'

    Description
    -----------
    Return volumes whose name matches a wildcard search

    .EXAMPLE
    Show-DockerContainerGridView -PassThru | Get-DockerVolume

    Description
    -----------
    Return volumes associated by container(s) selected interactively from a grid
    
    .NOTES
    Alias 'gdv'

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Name', Position = 0)]
        [SupportsWildcards()]
        [string[]]$Name,
        
        [Parameter(Mandatory, ParameterSetName = 'ContainerName')]
        [SupportsWildcards()]
        [string]$ContainerName,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Container')]
        [PSCustomObject]$Container
    )
    
    process
    {
        $selectVolumeName = { $_ | Select-Object -Exp Mounts | Select-Object -Exp Name }
        $getAllVolumeNames = { docker volume ls --format '{{.Name}}' }
        $volumes = switch ($PSCmdlet.ParameterSetName)
        {
            'List'
            { 
                & $getAllVolumeNames
            }
            'Name'
            {
                $allNames = & $getAllVolumeNames
                $Name | ForEach-Object {
                    $currentName = $_
                    $criteria = if ($currentName -match '\*')
                    {
                        { $_ -like $currentName }
                    }
                    else
                    {
                        { $_ -eq $currentName }
                    }
                    $allNames | Where-Object $criteria
                } | Select-Object -Unique
            }
            'ContainerName'
            {
                Get-DockerContainer -Name $ContainerName -Inspect | ForEach-Object $selectVolumeName
            }
            'Container'
            {
                $Container = if ($Container.PsObject.Properties.Name -notcontains 'Mounts')
                {
                    Get-DockerContainer -Name ($Container.Name) -Inspect
                }
                else
                {
                    $Container
                }
                $Container | ForEach-Object $selectVolumeName
            }
            Default
            {
                throw "ParameterSet '$PSCmdlet.ParameterSetName' not implemented"
            }
        }
        $volumes | ForEach-Object { [PsCustomObject](docker volume inspect $_ | ConvertFrom-Json) }
    }
}

Set-Alias -Name gdv -Value Get-DockerVolume
Export-ModuleMember -Alias gdv