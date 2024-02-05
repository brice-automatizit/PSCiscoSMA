function Test-SmaConnection {
    <#
    .SYNOPSIS

    Check current SMA Connexion.

    .DESCRIPTION

    Check if everything is fine to run another API calls or try to refresh token

    .EXAMPLE

    PS>Test-SmaConnection
        
    .INPUTS
        
    none

    .OUTPUTS
        
    void
    #>
    [CmdletBinding()]
    Param ()
    Begin {
    }
    Process {
        If (-not ($SMAApiBaseUri -and $SMAToken -and $SMACreds)) {
            throw 'Please run Connect-SMAApi -ServerUri "https://<your sma instance>:xxxx/sma/api/v2.0/" -SMACredential $(Get-Credential)'
        }
        $token = $SMAToken.jwtToken
        If (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { 
            throw "Invalid JWT token"
        } 
        #Payload
        $tokenPayload = $token.Split(".")[1].Replace('-', '+').Replace('_', '/')
        #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
        while ($tokenPayload.Length % 4) { 
            Write-Verbose "Invalid length for a Base-64 char array or string, adding =" 
            $tokenPayload += "=" 
        }
        #Convert B64 to PS Object
        $tokenDecodedObject = [System.Text.Encoding]::Default.GetString([System.Convert]::FromBase64String($tokenPayload)) | ConvertFrom-Json
        If (-not $tokenDecodedObject.exp) { throw "Invalid JWT token" }
        $remainingTime = ([datetime]'1/1/1970').AddSeconds($tokenDecodedObject.exp) - $(get-date).ToUniversalTime()
        If ($remainingTime.TotalSeconds -le 60) {
            Write-Warning "Token is expired or expiring very shortly. Will Try to renew it"
            Write-Verbose "Before: $($SMAToken.jwtToken)"
            Connect-SMAApi -ServerUri $SMAApiBaseUri -SMACredential $SMACreds
            Write-Verbose "After: $($SMAToken.jwtToken)"
        } else {
            Write-Verbose "Token still valid for $($remainingTime.TotalSeconds)s."
        }
    }
    End {
    }
}