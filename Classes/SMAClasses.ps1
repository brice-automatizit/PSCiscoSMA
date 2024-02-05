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
    [Int]$id
    [SMAMailDownloadedAttachments[]]$downloadedAttachments
    [System.IO.FileInfo]$localBody
    [System.IO.FileInfo]$localHeaders
}