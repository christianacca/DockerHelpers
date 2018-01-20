@{ 
    PSDependOptions = @{ 
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    # Add the *exact versions* of any dependencies of your module...
    # EG:
    'posh-docker'   = '0.7.1'
}