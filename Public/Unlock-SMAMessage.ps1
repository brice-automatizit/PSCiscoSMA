function Unlock-SMAMessage {
    <#
    .SYNOPSIS

    Release a mail from Quarantine

    .DESCRIPTION

    Release a mail from Quarantine

    .EXAMPLE
        
    PS>$isReleased = 757958 | Unlock-SMAMessage

    PS>$isReleased = Unlock-SMAMessage -Message [SMAMail]
    .INPUTS

    .OUTPUTS
        
    $true or $false
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
            Position = 1,
            ParameterSetName="WithMid"
        )]
        [int]
        $mid
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
                    "action"= "release";
                    "mids" = @($messageDetails.mid);
                    "quarantineType"= "pvo";
                    "quarantineName"= $messageDetails.attributes.quarantineDetails.quarantineName;
                }
            } else {
                $body = @{
                    "action"= "release";
                    "mids" = @($message.mid);
                    "quarantineType"= "pvo";
                    "quarantineName"= $message.attributes.inQuarantines;
                }
            }
            $uri = New-SMAQueryURL -endpoint "quarantine/messages" 
            $isReleased = Send-SmaApiRequest -uri $uri -Method "POST" -Body $body
        }
        catch {
            throw $_.Exception
        }
    }
    End {
        if ($isReleased.data -and $isReleased.data.totalCount -eq 1) {
            return $true
        } else {
            return $false
        }
    }
}