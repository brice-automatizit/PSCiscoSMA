function Search-SMATracking {
    <#
    .SYNOPSIS

    Returns the list of messages according search criterias.

    .DESCRIPTION

    Returns the list of messages according search criterias.
    With different attributes

    .EXAMPLE

    PS>Search-SMATracking -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -Limit 1000
        
    PS>Search-SMATracking -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -SenderFilter "toto"
    .INPUTS

    .OUTPUTS
        
    Object[]
    #>
    [CmdletBinding()]
    [CmdletBinding(DefaultParameterSetName="none")]
    #[OutputType('[SMAMail[]]', ParameterSetName="none")]
    Param (
        [Parameter(
            HelpMessage = 'Start Date to look for',
            Mandatory = $true,
            Position = 1
        )]
        [Datetime]
        $StartDate,
        [Parameter(
            HelpMessage = 'End Date to look for',
            Mandatory = $true,
            Position = 2
        )]
        [Datetime]
        $EndDate,
        [Parameter(
            HelpMessage = 'Recipient filter (contains)',
            Position = 3
        )]
        [string]
        $RecipientFilter,
        [Parameter(
            HelpMessage = 'Sender filter (contains)',
            Position = 4
        )]
        [string]
        $SenderFilter,
        [Parameter(
            HelpMessage = 'Limit the number of result',
            Position = 5
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [Nullable[System.Int32]]
        $limit = $null
    )
    Begin {
        Test-SmaConnection
        $arrayResults = [System.Collections.ArrayList]::new()
        $_limit = $limit
    }
    Process {
        if ($limit -eq $null -or $limit -gt 100) {
            $_limit = 100
        }
        $paramsSearchURL = @{
            "endpoint"="message-tracking/messages";
            "startDate"=$StartDate;
            "endDate"=$EndDate;
            "recipientFilterTracking"=$RecipientFilter;
            "senderFilterTracking"=$SenderFilter;
            "ciscoHost"="All_Hosts";
            "searchOption"="messages";
            "offset"=0;
            "limit"=$_limit;
        }
        Write-Verbose $($paramsSearchURL | ConvertTo-Json -Compress)

        Try {
            do {
                $uri =  New-SMAQueryURL @paramsSearchURL
                Write-Verbose "URI CALLED: $uri"
                $result = Send-SmaApiRequest -uri $uri
                $result.data | ForEach-Object { if ($_.attributes) { $arrayResults.Add([SMAMailTacked]$_.attributes) | Out-Null } }
                Write-Verbose "Results $($result.meta.totalCount). Size :$($arrayResults.Count)"
                if ($arrayResults.Count -ge $limit -or $result.meta.totalCount -eq 0) {
                    Write-Verbose "Limit reached or no more results. totalCount: $($result.meta.totalCount)"
                    break
                }
                $paramsSearchURL.offset += $($result.meta.totalCount + 1) # need to increase the offset to avoid duplicates
                
                if(($paramsSearchURL.offset + $_limit) -gt $limit) {
                    Write-Verbose "Need to decrease limit for next call to $($limit - $arrayResults.Count)"
                    $paramsSearchURL.limit = $limit - $arrayResults.Count
                }

                Write-Verbose "Increase offset to $($paramsSearchURL.offset)"
            }  while ($true)
        }
        catch {
            throw $_.Exception
        }
    }
    End {
        if ($arrayResults.Count -gt 0) {
            [SMAMailTacked[]]$arrayResults
        } else {
            return
        }
        
    }
}