function New-SMAQueryURL {
        <#
    .SYNOPSIS

    Helper to build URL according different parameters

    .DESCRIPTION

    Helper to build URL according different parameters

    .EXAMPLE

    PS>
        
    .INPUTS
        

    .OUTPUTS
        
    string
    #>
    [CmdletBinding()]

    Param (
        [string]$Endpoint,
        [string]$DeviceType,
        [string]$QuarantineType,
        [string]$Quarantine_Type,
        [nullable[Datetime]]$StartDate,
        [nullable[Datetime]]$EndDate,
        [string]$RecipientFilter,
        [string]$SenderFilter,
        [string]$Quarantines,
        [Nullable[System.Int32]]$Offset,
        [Nullable[System.Int32]]$Limit,
        [Nullable[System.Int32]]$Mid,
        [Nullable[System.Int32]]$AttachmentId
    ) 
    Begin {
        #todo check if there is already a SMAApiBaseUri ?
        Try {
            $nvCollectionTmp = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        } Catch {
            Add-Type -AssemblyName System.Web;
            $nvCollectionTmp = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        }
    }
    Process {
        $strUri = [System.UriBuilder]::new($SMAApiBaseUri.AbsoluteUri + $endpoint)
        if ($startDate) {
            $nvCollectionTmp.Add('startDate',$startDate.ToString("yyyy-MM-ddTHH:mm:00.000Z")) #seconds and microseconds arent supported
        }
        if ($quarantineType) {
            $nvCollectionTmp.Add("quarantineType","pvo")
        }
        if ($Quarantine_Type) {
            $nvCollectionTmp.Add("quarantine_type","pvo")
        }
        if ($quarantines) {
            $nvCollectionTmp.Add('quarantines',$quarantines)
        }
        if ($endDate) {
            $nvCollectionTmp.Add('endDate',$endDate.ToString("yyyy-MM-ddTHH:mm:00.000Z"))
        }
        if ($deviceType) {
            $nvCollectionTmp.Add("device_type","sma")
        }
        if ($recipientFilter) {
            $nvCollectionTmp.Add('envelopeRecipientFilterBy','contains')
            $nvCollectionTmp.Add('envelopeRecipientFilterValue',$recipientFilter)
        }
        if ($senderFilter) {
            $nvCollectionTmp.Add('envelopeSenderFilterBy','contains')
            $nvCollectionTmp.Add('envelopeSenderFilterValue',$senderFilter)
        }

        if ($offset -ne $null) {
            $nvCollectionTmp.Add("offset",$offset)
        }
        if ($limit -ne $null) {
            $nvCollectionTmp.Add("limit",$limit)
        }
        if ($mid -ne $null) {
            $nvCollectionTmp.Add("mid",$mid)
        }
        if ($attachmentId -ne $null) {
            $nvCollectionTmp.Add("attachmentId",$attachmentId)
        }

        $strUri.Query = $nvCollectionTmp.ToString()

        $([uri]::UnescapeDataString($strUri.Uri.OriginalString))
    }
}