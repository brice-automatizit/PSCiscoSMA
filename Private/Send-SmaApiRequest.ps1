function Send-SmaApiRequest {

    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = 'Get',

        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [System.Uri]
        $Uri,

        [Parameter(Position = 3)]
        [System.Object]
        $Body,

        [Parameter(Position = 4)]
        [Switch]
        $Raw
    )
    Begin {
        
    }
    Process {
        If (-not $SMAToken) {
            Try {
                $params = @{
                    Method      = $Method
                    Uri         = $uri
                    Body        = ($body | ConvertTo-Json -Depth 5)
                    ContentType = "application/json;charset=UTF-8"
                    Headers     = @{accept = "application/json"}
                }
                $WebResponse = Invoke-WebRequest @params
                $WebResponse.content | ConvertFrom-Json
            } Catch {
                throw $_
            }
        } Else { 
            Try {
                Write-Debug "Headers : $SMAToken"
                $params = @{
                    Method      = $Method
                    Uri         = $uri
                    ContentType = "application/json;charset=UTF-8"
                    Headers     = $SMAToken
                }
                Write-Debug "Params: $($params | convertto-json -Compress)"
                if ($null -ne $body) {
                    Write-Verbose "Adding body to payload"
                    $params.Add("Body",$($body | ConvertTo-Json))
                }
                $WebResponse = Invoke-WebRequest @params
                if ($Raw) {
                    $WebResponse.RawContentStream.ToArray()
                } else {
                    $WebResponse.content | ConvertFrom-Json
                }
                if ($WebResponse.Headers.jwtToken) {
                    Write-Verbose "Token present in Response header. Updating jwtToken accordingly"
                    Set-Variable -Name SMAToken -Value @{accept = 'application/json'; jwtToken = $WebResponse.Headers.jwtToken} -Option ReadOnly -Scope Script -Force
                }
            } Catch {
                throw $_
            }
        }
        

    }
    End {

    }

}