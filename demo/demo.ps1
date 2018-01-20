Unload-SUT
Import-Module ($global:SUTPath)

Get-DockerContainerIP

Get-DockerContainer '*series5-spa*' -Inspect | select -PV container |
ForEach-Object { $_.Mounts.Source } | 
ForEach-Object { [PsCustomObject]@{ Name = $container.Name; MountPath = $_ } }

return

Get-DockerContainer 'series5_*' -Inspect

Get-DockerContainer 'series5_*' | Show-DockerContainerGridView -PassThru -Inspect |
 Select-Object Name, @{n='Port'; e={ $_.Mounts.Source } }

Get-DockerContainer 'series5_*' -Inspect -PV container | select -Exp Config | select ExposedPorts |
select @{n='Name'; e={ $container.Name }}, @{n='ExposedPort'; e={$_} } 


(Get-DockerContainer 'series5_*' -Inspect -PV c | select -Exp Config).ExposedPorts
