function Move-SMAMessage {
    <#
    .SYNOPSIS

    Move a mail into another quarantine

    .DESCRIPTION

    Move a mail into another quarantine

    .EXAMPLE
        
    PS>$isMoved = 757958 | Move-SMAMessage -ToQuarantine "SPAM"

    PS>$isMoved = Move-SMAMessage -Message [SMAMail]  -ToQuarantine "SPAM"
    .INPUTS

    .OUTPUTS
        
    Object[]  #$detailsMessages = Invoke-SMACall $(New-SMAQueryURL -endpoint "quarantine/messages/details" -mid $mid -quarantineType "pvo")
    #>
    [CmdletBinding(DefaultParameterSetName="none")]
    [OutputType('[bool]', ParameterSetName="none")]
    Param (
        [Parameter(
            HelpMessage = 'Message',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName="WithSMAMail"
        )]
        [SMAMail]
        $message,
        [Parameter(
            HelpMessage = 'Message Detailled',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName="WithSMAMailDetails"
        )]
        [SMAMailDetails]
        $messageDetails,
        [Parameter(
            HelpMessage = 'Message ID',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName="WithMid"
        )]
        [int]
        $mid,
        [Parameter(
            HelpMessage = 'Destination Quarantine',
            Mandatory = $true,
            Position = 1
        )]
        [string]
        $ToQuarantine
    )
    Begin {
        Test-SmaConnection
    }
    Process {
        if ($mid) {
            Write-Verbose "Message Id specified. Need to grab the messages"
            $messageDetails = $mid | Get-SMAMessageDetails
        }
        try {
            if ($messageDetails) {
                $body = @{
                    "action"= "move";
                    "mids" = @($messageDetails.mid);
                    "quarantineType"= "pvo";
                    "quarantineName"= $messageDetails.attributes.quarantineDetails.quarantineName;
                    "destinationQuarantineName"=$ToQuarantine
                }    
            } else {
                $body = @{
                    "action"= "move";
                    "mids" = @($message.mid);
                    "quarantineType"= "pvo";
                    "quarantineName"= $message.attributes.inQuarantines;
                    "destinationQuarantineName"=$ToQuarantine
                }                 
            }
            $uri = New-SMAQueryURL -endpoint "quarantine/messages" 
            $isMoved = Send-SmaApiRequest -uri $uri -Method "POST" -Body $body
        }
        catch {
            throw $_.Exception
        }
    }
    End {
        if ($isMoved.data -and $isMoved.data.totalCount -eq 1) {
            return $true
        } else {
            return $false
        }
    }
}