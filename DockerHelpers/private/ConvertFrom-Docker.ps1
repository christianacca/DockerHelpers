<#
.SYNOPSIS

Converts from docker output to objects
.DESCRIPTION

Converts from docker tabular output to objects that can be worked with in a familiar way in PowerShell

.EXAMPLE
Get the running containers and 

docker ps -a --no-trunc | ConvertFrom-Docker | ft

.NOTES
Original source: https://github.com/samneirinck/posh-docker/blob/3f8645196209ff7fd7090bcf1176307315b1ab30/posh-docker/posh-docker.psm1#L259-L284
Copywrite/licence: https://github.com/samneirinck/posh-docker/blob/master/LICENSE

#>
function ConvertFrom-Docker{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
		ValueFromPipeline=$True)]
		[object[]]$items
    )
    
    begin{
        $positions = $null;
    }
    process {
        foreach ($item in $items)
        {
            if($null -eq $positions) {
                # header row => determine column positions
                $positions  = GetColumnInfo -headerRow $item
            } else {
                # data row => output!
                ParseRow -row $item -columnInfo $positions
            }
        }
    }
    end {
    }
}