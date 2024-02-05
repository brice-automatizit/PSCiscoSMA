function Connect-SMAApi {
    <#
    .SYNOPSIS

    Set internal variables for connexion.

    .DESCRIPTION

    Set internal variables for connexion.

    .PARAMETER  ServerUri
        
    System.Uri
    This is the fully qualified URI of your SMA instance. ex: https://host-sma1.domain.iphmx.com:4431/sma/api/v2.0/"

    .PARAMETER SMACredential

    System.Management.Automation.PSCredential
    This is the username credential you will use to authenticate.

    .EXAMPLE

    PS>Connect-SMAApi -ServerUri 'https://host-sma1.domain.iphmx.com:4431/sma/api/v2.0/' -SMACredential (Get-Credential)
        
    .INPUTS
        
    System.Uri
    System.Management.Automation.PSCredential

    .OUTPUTS
        
    void
    #>
    [CmdletBinding(DefaultParameterSetName = 'Credential')]
    [Alias('pssmacon')]
    Param (
        [Parameter(
            HelpMessage = 'The fully qualified URI of the server. Do not include the API path.',
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Credential'
        )]
        [System.Uri]
        $ServerUri,

        [Parameter(
            HelpMessage = 'username@realm credential',
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Credential'
        )]
        [PSCredential]
        $SMACredential
    )
    Begin {
        # Remove any module-scope variables in case the user is reauthenticating
        Remove-Variable -Scope Script -Name SMAApiBaseUri,SMAToken, SMACreds -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Process {

        if ($PSCmdlet.ParameterSetName -eq 'Credential') { 
            $body = @{
                    data = @{
                        userName = 
                            [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SMACredential.UserName)); #[System.Text.Encoding]::Default or utf8??
                        passphrase = 
                            [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SMACredential.GetNetworkCredential().Password))
                    }
            }

            try {
                Write-Verbose "URI From Connect-SMAAPI: $($ServerUri.AbsoluteUri + 'login')"
                Write-Verbose "Body: $($body | ConvertTo-Json)"
                $request = Send-SmaApiRequest -Method Post -Uri ($ServerUri.AbsoluteUri + 'login') -Body $body
            }
            catch {
                throw $_.Exception
            }

        }
    }
    End {

        if ($request -and $request.data -and $request.data.jwtToken) { # Authentication was successfull. Initialize this module-scope variable.
            Set-Variable -Name SMAApiBaseUri -Value $ServerUri -Option ReadOnly -Scope Script -Force
            Set-Variable -Name SMAToken -Value @{accept = 'application/json'; jwtToken = $request.data.jwtToken} -Option ReadOnly -Scope Script -Force
            Set-Variable -Name SMACreds -Value $SMACredential -Option ReadOnly -Scope Script -Force
            Write-Verbose "Authenticated to SMA"
        }
        else {
            return
        }
    }

}