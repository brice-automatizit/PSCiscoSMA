function Search-SMAQuarantines {
    <#
    .SYNOPSIS

    Returns the list of messages according search criterias.

    .DESCRIPTION

    Returns the list of messages according search criterias.
    With different attributes

    .EXAMPLE

    PS>Search-SMAQuarantines -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -Quarantine "VIRUS" -SenderFilter "toto@toto.com"
        
    PS>Search-SMAQuarantines -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -SenderFilter "toto"
    .INPUTS

    .OUTPUTS
        
    Object[]
    #>
    [CmdletBinding()]
    [CmdletBinding(DefaultParameterSetName="none")]
    [OutputType('[SMAMail[]]', ParameterSetName="none")]
    Param (
        [Parameter(
            HelpMessage = 'Limit to 100 results',
            Position = 0
        )]
        [switch]
        $LimitResults,
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
            HelpMessage = 'List of Quarantines to look for (default All)',
            Position = 5
        )]
        [Object[]]
        $Quarantines
    )
    Begin {
        Test-SmaConnection
        $arrayResults = [System.Collections.ArrayList]::new()
    }
    Process {
        if (-not $Quarantines) {
            $selectedQuarantines = $(Get-SMAQuarantines -AsArray) -join "," -replace " ","+"
        } else {
            $selectedQuarantines = $($quarantines) -join "," -replace " ","+"
            Write-Verbose "Quarantines manually specified: $selectedQuarantines"
        }

        $paramsSearchURL = @{
            "endpoint"="quarantine/messages";
            "startDate"=$StartDate;
            "endDate"=$EndDate;
            "recipientFilter"=$RecipientFilter;
            "senderFilter"=$SenderFilter;
            "quarantineType"="pvo";
            "quarantines"=$selectedQuarantines;
            "offset"=0;
            "limit"=100;
        }

        Write-Verbose $($paramsSearchURL | ConvertTo-Json -Compress)

        Try {
            do {
                $uri = New-SMAQueryURL @paramsSearchURL
                Write-Verbose "URI called: $uri"
                $result = Send-SmaApiRequest -uri $uri
                $result.data | ForEach-Object { $arrayResults.Add([SMAMail]$_) | Out-Null }
                Write-Verbose "Results $($result.meta.totalCount). Size :$($arrayResults.Count)"

                Write-Verbose ($LimitResults)
                Write-Verbose ( ($arrayResults | Measure-Object | Select-Object -ExpandProperty Count) -ge $result.meta.totalCount)

                if ($LimitResults -or 
                    ( ($arrayResults | Measure-Object | Select-Object -ExpandProperty Count) -ge $result.meta.totalCount) ) {
                    break
                } else {
                    $paramsSearchURL.offset += 100
                    Write-Verbose "$($paramsSearchURL.offset) / $($result.meta.totalCount)"                    
                }
            }  while ($true)
        }
        catch {
            throw $_.Exception
        }
    }
    End {
        if ($result -and $result.meta -and $result.meta.totalCount) {
            [SMAMail[]]$arrayResults
        } else {
            return
        }
        
    }
}