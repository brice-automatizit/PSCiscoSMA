function Get-SMAMessageTrackingDetails {
    <#
    .SYNOPSIS

    Returns the tracking details of a message.

    .DESCRIPTION

    Returns the tracking details of a message.

    .EXAMPLE

    PS>
        
    .INPUTS

    .OUTPUTS
        
    #>
    #[CmdletBinding(DefaultParameterSetName="none")]
    [CmdletBinding()]
    #[OutputType('[SMAMailTrackingDetails]', ParameterSetName="none")]
    Param (
        [Parameter(
            HelpMessage = 'Message',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName="WithSMAMailTacked"
        )]
        [SMAMailTacked]
        $message
    )
    Begin {
        Test-SmaConnection
        $format = "dd MMM yyyy HH:mm:ss '(GMT' zzz')'"
        $culture = [System.Globalization.CultureInfo]::InvariantCulture
    }
    Process {
        if ($message) {
            Write-Verbose "Message Object specified"
            try {
                $paramsSearchURL = @{
                    "endpoint"="message-tracking/details";
                    #"startDate"=$([datetime]::ParseExact($message.timestamp, $format, $culture)).ToUniversalTime().AddMinutes(-2);
                    #"endDate"=$([datetime]::ParseExact($message.timestamp, $format, $culture)).ToUniversalTime().AddMinutes(2);
                    "startDate"=$([datetime]::ParseExact($message.timestamp, $format, $culture));
                    "endDate"=$([datetime]::ParseExact($message.timestamp, $format, $culture));
                    "mids"=$message.mid
                    #"icids"=$message.icid #not mandatory
                    #"dcid"=$message.dcid # not mandatory
                    "serialNumber"=$message.serialNumber
                }
                $uri = New-SMAQueryURL @paramsSearchURL
                Write-Verbose "URI called: $uri"
                $details = Send-SmaApiRequest -Uri $uri
            }
            catch {
                throw $_.Exception
            }
        } else {
            throw "Please specify either an mid or a message"
        }
    }
    End {
        if ($details -and $details.data -and $details.data.messages) {
            $details.data.messages
        } else {
            return
        }
    }
}