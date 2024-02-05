# PSCiscoSMA

[![PowerShell Gallery][psgallery-badge]][psgallery]

A PowerShell module for interfacing with the Cisco SMA (Secure Management Appliance, ex-Ironport) API
Currently support only standard authentication. 

Support token refresh when expired (through response headers sent by Cisco or explicitely by a complete reconnect)

## Usage

### Install

```PowerShell
PS> Install-Module PSCiscoSMA
```

### Import

```PowerShell
PS> Import-Module PSCiscoSMA
```

### Connect

```PowerShell
PS> Connect-SMAApi -ServerUri "https://<your instance url>:xxx/sma/api/v2.0/" -SMACredential $(Get-Credential)
```

### Example for unattended

```PowerShell
PS> # Save credentials
PS> Get-Credential | Export-CliXml "$($ENV:USERPROFILE)\psciscosma.xml"
PS> # Use those save credentials (same computer, same windows session)
PS> Connect-SMAApi -ServerUri "https://<your instance url>:xxx/sma/api/v2.0/" -SMACredential $(Import-CliXml "$($ENV:USERPROFILE)\psciscosma.xml")
```

### Get availables quarantines 

```PowerShell
PS> $availablesQuarantines = Get-SMAQuarantines
```

Advanced Options:

* Specify the ```-AsArray``` flag to retrieve all quarantines as an array.

### Search

Search mails with sender address containing "john" up to 3 days ago

```PowerShell
PS> $mails = Search-SMAQuarantines -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -SenderFilter "john"
```

Search all mails up to 3 days ago in quarantines named SPAM and VIRUS

```PowerShell
PS> $others = Search-SMAQuarantines -EndDate $(get-Date) -StartDate $(get-date).AddDays(-3) -Quarantines "SPAM,VIRUS"
```

### Get details

From pipeline

```PowerShell
PS> $mailDetails = $mails | % { $_ | Get-SMAMessageDetails }
```

Through a mail object

```PowerShell
PS> Get-SMAMessageDetails -message $mails[0]
```

Through an MID

```PowerShell
PS> Get-SMAMessageDetails -mid 12345
```

### Download mail & content (attachment, headers and body)

```PowerShell
PS> $path = $($ENV:USERPROFILE)
PS> $downloadedItems = $mails[0] | Save-SMAMessageAttachments -path $path
```

### Move mail to another quarantine (through a mail object or id from pipline or through args)

```PowerShell
PS> 12345 | Move-SMAMessage -ToQuarantine "WAITING"
```

### Release mail

```PowerShell
PS> 12345 | Unlock-SMAMessage
```


[psgallery-badge]:      https://img.shields.io/powershellgallery/dt/PSCiscoSMA.svg
[psgallery]:            https://www.powershellgallery.com/packages/PSCiscoSMA