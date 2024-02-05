function Get-SMAQuarantines {
    <#
    .SYNOPSIS

    Returns the list of availables quarantines.

    .DESCRIPTION

    Returns the list of availables quarantines.
    This can be usefull to for filtering choices

    .EXAMPLE

    PS>Get-SMAQuarantines
        
    .INPUTS

    .OUTPUTS
        
    PSCustomObject or array of string
    #>
    [CmdletBinding()]
    [CmdletBinding(DefaultParameterSetName="none")]
    [OutputType('[System.Object]', ParameterSetName="none")]
    [OutputType('[System.Array]', ParameterSetName="AsArray")]
    Param (
        [Parameter(
            HelpMessage = 'Return all available in on array',
            Position = 0,
            ParameterSetName = 'AsArray'
        )]
        [switch]
        $AsArray
    )
    Begin {
        Test-SmaConnection
    }
    Process {
        try {
            $uri = New-SMAQueryURL -endpoint "config/quarantines" -deviceType "sma" -quarantine_type "pvo"
            Write-Verbose "URI called: $uri"
            $request = Send-SmaApiRequest -Uri $uri
        }
        catch {
            throw $_.Exception
        }
    }
    End {
        if ($request -and $request.data -and $request.data.quarantines) {
            if ($AsArray) {
                $($request.data.quarantines.PSObject.Properties.Name | ForEach-Object {
                    $request.data.quarantines.$_ | ForEach-Object { $_ }
                })
            } else {
                $request.data.quarantines
            }
        }
        else {
            return
        }
    }
}