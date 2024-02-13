# Classes for parameter validation
class SMAMailAttributes {
    [String]$esaHostName
    [Int]$esaMid
    [String]$inQuarantines
    [String]$originatingEsaIp
    [Object[]]$quarantineForReason
    [Object[]]$quarantineForReasonDict
    [String]$received
    [Object[]]$recipient
    [String]$scheduledExit
    [String]$sender
    [String]$size
    [String]$subject
}

class SMAMail {
    [SMAMailAttributes]$attributes
    [Int]$mid
}

class SMAMailDetailsAttributes {
    [String]$headers
    [Object[]]$matchedContents
    [String]$messageBody
    [PSCustomObject]$messageDetails
    [Object[]]$messagePartDetails
    [Object[]]$quarantineDetails
}


class SMAMailDetails {
    [SMAMailDetailsAttributes]$attributes
    [Int]$mid
}




class SMAMailDownloadedAttachments {
    [int]$Id
    [System.IO.FileInfo]$LocalItem
    [string]$LocalSizeB64
    [string]$SMAName
    [string]$SMASize
    [bool]$CorrectlyDownloaded
}

class SMAMailDownloaded {
    [SMAMailDetails]$MessageDetails
    [SMAMailDownloadedAttachments[]]$downloadedAttachments
    [System.IO.FileInfo]$localBody
    [System.IO.FileInfo]$localHeaders
}


class SMAMailTacked {
    [Object[]]$allIcid
    [Object[]]$dcid
    [string]$direction
    [PSCustomObject]$finalSubject
    [Object[]]$friendly_from
    [string]$hostName
    [int]$icid
    [string]$isCompleteData
    [Object[]]$mailPolicy
    [PSCustomObject]$messageID
    [PSCustomObject]$messageStatus
    [Object[]]$mid
    [PSCustomObject]$morDetails
    [PSCustomObject]$morInfo
    [Object[]]$recipient
    [PSCustomObject]$recipientMap
    [string]$replyTo
    [string]$sbrs
    [string]$sender
    [string]$senderDomain
    [string]$senderGroup
    [string]$senderIp
    [string]$serialNumber
    [string]$subject
    [string]$timestamp
    [PSCustomObject]$verdictChart
}
