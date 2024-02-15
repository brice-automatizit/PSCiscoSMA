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
        [string]$RecipientFilterTracking,
        [string]$SenderFilterTracking,
        [string]$Quarantines,
        [Nullable[System.Int32]]$Offset,
        [Nullable[System.Int32]]$Limit,
        [Nullable[System.Int32]]$Mid,
        [Nullable[System.Int32]]$AttachmentId,
        [string]$CiscoHost,
        [string]$SearchOption,
        [int[]]$mids,
        [int[]]$icids,
        [Nullable[System.Int32]]$dcid,
        [string]$serialNumber
    ) 
    Begin {
        #todo check if there is already a SMAApiBaseUri ?
        Try {
            [System.Reflection.Assembly]::GetAssembly([System.Web.HttpUtility]) | Out-Null
            $nvCollectionTmp = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        } Catch {
            Add-Type -AssemblyName System.Web;
            $nvCollectionTmp = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        }
    }
    Process {
        $strUri = [System.UriBuilder]::new($($SMAApiBaseUri.AbsoluteUri + $endpoint))
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
        if ($RecipientFilterTracking) {
            $nvCollectionTmp.Add('envelopeRecipientfilterOperator','contains')
            $nvCollectionTmp.Add('envelopeRecipientfilterValue',$RecipientFilterTracking)
        }
        if ($SenderFilterTracking) {
            $nvCollectionTmp.Add('envelopeSenderfilterOperator','contains')
            $nvCollectionTmp.Add('envelopeSenderfilterValue',$SenderFilterTracking)
        }
        if ($mid -ne $null) {
            $nvCollectionTmp.Add("mid",$mid)
        }
        if ($attachmentId -ne $null) {
            $nvCollectionTmp.Add("attachmentId",$attachmentId)
        }
        if ($ciscoHost) {
            $nvCollectionTmp.Add('ciscoHost',$ciscoHost)
        }
        if ($searchOption) {
            $nvCollectionTmp.Add('searchOption',$searchOption)
        }
        if ($offset -ne $null) {
            $nvCollectionTmp.Add("offset",$offset)
        }
        if ($limit -ne $null) {
            $nvCollectionTmp.Add("limit",$limit)
        }
        foreach ($_mid in $mids) {
            $nvCollectionTmp.Add("mid",$_mid)
        }
        foreach ($_icid in $icids) {
            $nvCollectionTmp.Add("icid",$_icid)
        }
        if ($dcid -ne $null) {
            $nvCollectionTmp.Add("dcid",$dcid)
        }
        if ($serialNumber) {
            $nvCollectionTmp.Add('serialNumber',$serialNumber)
        }
        $strUri.Query = $nvCollectionTmp.ToString()   
        [uri]::UnescapeDataString($strUri.Uri.OriginalString) #$strUri.Uri.OriginalString
    }
}