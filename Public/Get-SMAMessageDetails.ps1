function Get-SMAMessageDetails {
    <#
    .SYNOPSIS

    Returns the details of a message.

    .DESCRIPTION

    Returns the details of a message.

    .EXAMPLE

    PS>$detailedMails = Search-SMAQuarantines -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -Quarantine "MACRO" | ForEach-Object { $_ | Get-SMAMEssageDetails } 
        
    PS>$detailMail = 45343 | Get-SMAMEssageDetails

    PS>$detailMail = Get-SMAMEssageDetails -Message [SMAMail]
    .INPUTS

    .OUTPUTS
        
    Object[]  #$detailsMessages = Invoke-SMACall $(New-SMAQueryURL -endpoint "quarantine/messages/details" -mid $mid -quarantineType "pvo")
    #>
    [CmdletBinding(DefaultParameterSetName="none")]
    [OutputType('[SMAMailDetails]', ParameterSetName="none")]
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
        if ($message) {
            Write-Verbose "Message Object specified"
            $mid = $message.mid
        }
        if ($mid) {
            try {
                $uri = New-SMAQueryURL -endpoint "quarantine/messages/details" -mid $mid -quarantineType "pvo"
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
        if ($details -and $details.data) {
            [SMAMailDetails]$details.data
        } else {
            return
        }
    }
}