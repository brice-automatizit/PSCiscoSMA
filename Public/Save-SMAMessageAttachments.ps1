function Save-SMAMessageAttachments {
    <#
    .SYNOPSIS

    Download the attachments to a local folder.

    .DESCRIPTION

    Download the attachments to a local folder.
    Usefull for running actions on those

    .EXAMPLE

    PS>Get-SMAMessageDetails 
        
    .INPUTS

    .OUTPUTS
        
    Object[]  #$detailsMessages = Invoke-SMACall $(New-SMAQueryURL -endpoint "quarantine/messages/details" -mid $mid -quarantineType "pvo")
    #>
    [CmdletBinding(DefaultParameterSetName="none")]
    [OutputType('[SMAMailDownloaded]', ParameterSetName="none")]
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
            HelpMessage = 'Message Details',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1,
            ParameterSetName="WithSMAMailDetails"
        )]
        [SMAMailDetails]
        $messageDetails,
        [Parameter(
            HelpMessage = 'Folder Path to store',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [string]
        $path #todo: add script validation and more compatibility
    )
    Begin {
        Test-SmaConnection
        $arrayAttachments = [System.Collections.ArrayList]::new()
        #from: https://stackoverflow.com/a/23067832
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    }
    Process {
        if ($message) {
            Write-Verbose "Message Object specified. Need to get the details"
            $messageDetails = $message | Get-SMAMessageDetails
        }
        if ($messageDetails) {
            $attachments = $messageDetails.attributes.messagePartDetails | Where-Object { $_.attachmentName -ne '[message body]' }
            Write-Verbose "Message Details obtained. Found $($attachments.count) attachment(s)"
            Try {
                foreach ($attachment in $attachments) {
                    # generate an unique name to avoid conflits and sanistize the name to allow storage on local FS
                    $cleanedName = "$($messageDetails.mid)_" + [guid]::NewGuid().ToString() + $($attachment.attachmentName -replace "[${invalidChars}]",'_')
                    $filePath = Join-Path $path $cleanedName
                    $filePathB64 = Join-Path $path $($cleanedName + "-b64")

                    $paramsDownload = @{
                        "endpoint"="quarantine/messages/attachment"
                        "mid"=$messageDetails.mid
                        "quarantineType"="pvo"
                        "attachmentId"=$($attachment.attachmentId)
                    }
                    $uri = New-SMAQueryURL @paramsDownload
                    Write-Verbose "Downloading attachment through $uri"
                    $tmpB64String = [System.Text.Encoding]::UTF8.GetString($(Send-SmaApiRequest -uri $uri -Raw))
                    [io.file]::WriteAllBytes($filePath, [System.Convert]::FromBase64String( $tmpB64String ))
                    
                    # verify the size of the downloaded file through the B64 file as the size reported by SMA is based on B64 version of file
                    $tmpB64String | Set-Content -literalPath $filePathB64
                    $resultFile = Get-Item -literalPath $filePathB64
                    
                    $reportedSize = [double]$($attachment.attachmentSize -replace "K|M","")
                    $percentDifferenceWarning = 0.1
                    switch -Regex ($attachment.attachmentSize) {
                        '\dM' {
                            $mesuredSize = "$([math]::Round($resultFile.Length / 1024 / 1024,2))"
                        }
                        '\dK' {
                            $mesuredSize = "$([math]::Round($resultFile.Length / 1024,2))"
                            $percentDifferenceWarning*=50
                        }
                        default {
                            $mesuredSize = $resultFile.Length
                            $percentDifferenceWarning*=100
                        }
                    }
                    $difference = [math]::Round(($reportedSize - $mesuredSize) / ($reportedSize) * 100)
                    if ($difference -lt -$percentDifferenceWarning -or $difference -gt $percentDifferenceWarning) {
                        Write-Warning "Size not correct for $($attachment.attachmentName): SMA Size is $reportedSize and Downloaded B64 size if $mesuredSize"
                    }
                    
                    $arrayAttachments.Add([SMAMailDownloadedAttachments]@{
                        Id = $attachment.attachmentId
                        SMASize = $attachment.attachmentSize
                        SMAName = $attachment.attachmentName
                        LocalItem = Get-Item -literalPath $filePath
                        LocalSizeB64 = $mesuredSize
                        CorrectlyDownloaded = -not ($difference -lt -$percentDifferenceWarning -or $difference -gt $percentDifferenceWarning)
                    }) | Out-Null
                    Remove-Item -LiteralPath $filePathB64
                }
                # exporting body
                $cleanedBodyName = "$($messageDetails.mid)_body_" + [guid]::NewGuid().ToString() + ".html"
                $pathBody = $(Join-Path $path $cleanedBodyName)
                $messageDetails.attributes.messageBody | Set-Content -literalPath $pathBody
                # exporting headers
                $cleanedHeadersName = "$($messageDetails.mid)_headers_" + [guid]::NewGuid().ToString() + ".html"
                $pathHeaders = $(Join-Path $path $cleanedHeadersName)
                $messageDetails.attributes.headers | Set-Content -literalPath $pathHeaders
            } catch {
                throw $_.Exception
            }
        } else {
            throw "No message details Found"
        }
    }
    End {
        if ($messageDetails) {
            [SMAMailDownloaded]@{
                MessageDetails = $messageDetails
                DownloadedAttachments= $arrayAttachments
                LocalBody = Get-Item -literalPath $pathBody
                LocalHeaders = Get-Item -literalPath $pathHeaders
            }
        } else {
            return
        }
    }
}