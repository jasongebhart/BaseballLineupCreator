<#
.Synopsis 

.Description
	This module provides functions to generate HTML content for creating web page that displays lineup detail for baseball. 

.Parameter $GameDetail

.Example
Set-HTML -GameDetail $GameDetail

.Notes
File: HTMLBaseball.psm1
Date: August 8, 2023
#>
# Functions
Function New-HTMLHead {
    [Cmdletbinding()]
    [OutputType([Array])]
    param (
        [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $css,
        [Parameter(Position=1, Mandatory=$true,ValueFromPipeline = $true)]
        $HtmlTitle
        )
    Begin {
        $HTMLHead = @()
        $HTMLHeaderStart = @()
        $HTMLHeaderStart ="<!DOCTYPE html>`n"
        $HTMLHeaderStart +="<html lang=`"en`">`n"
        $HTMLHeaderStart +="<head>`n"
        $HTMLHeaderStart +="<meta charset=`"UTF-8`">`n"
        $HTMLHeaderStart +="<title>$HtmlTitle</title>`n"
        $HTMLHeaderStart +="<style type=`"text/css`">`n"
            
        $HTMLHeaderEnd = @()
        $HTMLHeaderEnd = "</style>`n"
        $HTMLHeaderEnd +="</head>`n"
        $HTMLHeaderEnd +="<body>`n"
    }
    process {
        $css = foreach ($line in $css) {$line + "`n"}
        $HTMLHead += $HTMLHeaderStart + $css + $HTMLHeaderEnd
        }
    end {
        [Array]$HTMLHead
        }
}
Function Get-CSS {
    [Cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $path
        )

    If (test-Path -Path $path) {
        $cssfile = Get-Content -Path $path
    } else {
        Write-Warning -Message "$path Does not exist...exiting"
        Exit
    }
    $cssfile
}
Function New-HTMLHeaderTitle {
[Cmdletbinding()]
    [OutputType([Array])]
    param (
        [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $headerone,
        [Parameter(Position=1, Mandatory=$false,ValueFromPipeline = $true)]
        $headertwo=$null
        )
    Begin {
        $HTMLHeaderTitle = @()
        $HTMLHeaderTitle += "`t<div id=`"header-title`">`n"
        }
    Process {
        $HTMLHeaderTitle += "`t`t<h1>$headerone</h1>`n"
        
        If ($headertwo) {
            $HTMLHeaderTitle += "`t`t<h2>$headertwo</h2>`n"
        }
        }
     End {
        $HTMLHeaderTitle += "`t</div>`n"
        [Array]$HTMLHeaderTitle
       }
}
Function New-HTMLHeader {
[Cmdletbinding()]
    [OutputType([Array])]
    param (
        [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $HTMLHeaderTitle,
        [Parameter(Position=1, Mandatory=$false,ValueFromPipeline = $true)]
        $HTMLNavigation
        )
    Begin {
            $HTMLHeader = @()
            $HTMLHeader += "<header>`n"
        }
    Process {
        $HTMLHeader += $HTMLHeaderTitle
        If ($HTMLNavigation) {
            $HTMLHeader += $HTMLNavigation
        }
        }
     End {
       $HTMLHeader += "</header>`n"
       [Array]$HTMLHeader
       }
}
Function New-MenuBar {
  [Cmdletbinding()]
    [OutputType([Array])]
    param (
    [Parameter(Position=0, Mandatory=$false,ValueFromPipeline = $true)]
        $content=$null,
    [Parameter(Position=1, Mandatory=$false,ValueFromPipeline = $true)]
        $ID=$null
    )
    Begin {
            $HTMLMenuBar = @()
            If ($ID) {
                $HTMLMenuBar += "<nav id=`"$ID`">`n"
            }else{$HTMLMenuBar += "<nav>`n"}
            $HTMLMenuBar += "`t<ul>`n"
       
          }

    Process{
            Foreach ($LineItem in $content) { 
                $HTMLMenuBar += "`t`t<li>$LineItem</li>`n"
            }
            }
    End {
       $HTMLMenuBar += "`t</ul>"
       $HTMLMenuBar += "</nav>`n"
       [Array]$HTMLMenuBar
       }
}
Function New-HTMLFooter {
  [Cmdletbinding()]
  [OutputType([String])]
    param (
    [Parameter(Position=0, Mandatory=$false,ValueFromPipeline = $true)]
        $footer=$null
    )
$HTMLFooter = @"
<footer>
    $footer
    <nav>
        <ul>
            <li>
                Copyright: © Jason Gebhart 2017
            </li>
            <li>
                <a href="#top">
                    <div>
                        Top
                    </div>
                </a>
            </li>
        </ul>
    </nav>
</footer>
"@
[String]$HTMLFooter
}
Function New-HTMLEnd {
$HTMLEnd = @"
</body>
</html>
"@
$HTMLEnd
}

Function New-HTMLGameDay {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $GameInfo=$null
    )
    #$GameDate = $GameInfo.GameDate.tostring("MM-dd-yyyy")
    $GameDate = $GameInfo.GameDate
    $HTMLGameDay = 
@"
<div id="game-info">
<p>Date: $GameDate</p>
<p>Location: $($GameInfo.Location)</p>
<p>Time: $($GameInfo.StartTime)</p>
</div>
"@
$HTMLGameDay
}

Function New-HTMLRuns {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $GameInfo=$null
    )
$HTMLRuns = @"
<div id="game-runs">
<h2>Runs</h2>
<table> <colgroup><col/><col/></colgroup>
<tr><th>Team</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th></tr>
<tr><td>$($GameInfo.Awayteam)</td><td> </td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td>$($GameInfo.Hometeam)</td><td></td></tr>
</table>
</div>
"@
$HTMLRuns
}

Function New-HTMLDugOutWhileBatting {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $DugoutJobs=$null
    )
$HTMLDugOutWhileBatting = @"
<div id="game-batting">
<h3>At Bat</h3>
<table> <colgroup><col/><col/></colgroup>
<tr><td>Lineup & Bat</td><td>$($DugoutJobs.LineupCoach)</td></tr>
<tr><td>3B Coach</td><td>$($DugoutJobs.ThirdBaseCoach)</td></tr>
<tr><td>1B Coach</td><td>$($DugoutJobs.FirstBaseCoach)</td></tr>
<tr><td>Pitch Count</td><td>$($DugoutJobs.PitchCounterOne) & $($DugoutJobs.PitchCounterTwo)</td></tr>
<tr><td>Balls, Strikes, & Outs</td><td>$($DugoutJobs.BallsStrikesOutsCoach)</td></tr>
<tr><td>ScoreKeeper</td><td>$($DugoutJobs.ScoreKeeper)</td></tr>
</table>
</div>
"@
$HTMLDugOutWhileBatting
}

Function New-HTMLDugOutWhilefielding {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $DugoutJobs=$null
    )
$HTMLDugOutWhilefielding = @"
<div id="game-fielding">
<h3>In The Field</h3>
<table> <colgroup><col/><col/></colgroup>
<tr><td>Positions</td><td>$($DugoutJobs.LineupCoach)</td></tr>
<tr><td>Pitch Count</td><td>Bench One</td></tr>
<tr><td>ScoreKeeper</td><td>Bench Two</td></tr>
<tr><td>Balls, Strikes, & Outs</td><td>Bench Three</td></tr>
</table>
</div>
</div>
"@
$HTMLDugOutWhilefielding
}

Function New-HTMLDugOutDuties {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$false,ValueFromPipeline = $true)]
        $HTMLDugOutWhileBatting=$null,
    [Parameter(Position=1, Mandatory=$false,ValueFromPipeline = $true)]
        $HTMLDugOutWhilefielding=$null
    )
$HTMLDugOutDuties = @"
<div id="game-dugout">
<h2>Dugout Duties</h2>
$HTMLDugOutWhileBatting
$HTMLDugOutWhilefielding
</div>
"@
$HTMLDugOutDuties
}


Function New-HTMLLineup {
  [Cmdletbinding()]
    param (
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        $NewLineup=$null
    )
    $properties = @(
        @{Name="Number"; Expression={$_.Number}}
        "Name"
        @{Name="1"; Expression={$_.Inning1}}
        @{Name="2"; Expression={$_.Inning2}}
        @{Name="3"; Expression={$_.Inning3}}
        @{Name="4"; Expression={$_.Inning4}}
        @{Name="5"; Expression={$_.Inning5}}
        @{Name="6"; Expression={$_.Inning6}}
     )
    
    $HTMLLineupTable = $NewLineup | Select-Object $properties | ConvertTo-Html -Fragment
      
$HTMLLineupTable = $HTMLLineupTable -replace "</tr>","</tr>`r`n"
$HTMLLineupTable = $HTMLLineupTable -replace '<th>"replaceMe"</th>','<th></th>'
$OriginalTableHeaders = "<th>1</th><th>2</th><th>3</th><th>4</th><th>5</th></tr>"
$ReplacementTableHeaders = "<th>1</th><th></th><th>2</th><th></th><th>3</th><th></th><th>4</th><th></th><th>5</th><th></th></tr>"
$HTMLLineupTable = $HTMLLineupTable -replace $OriginalTableHeaders,$ReplacementTableHeaders
$HTMLLineupTable = $HTMLLineupTable -replace "<td>1B</td>",'<td>1B</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> H </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>2B</td>",'<td>2B</td><td class="hitresult"> 2B </br> 2B </br> 3B </br> H </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>3B</td>",'<td>3B</td><td class="hitresult"> 3B </br> 2B </br> 3B </br> H </br> BB </br> O</span></td>'
#$HTMLLineupTable = $HTMLLineupTable -replace "B</td>",'B</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>SS</td>",'<td>SS</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>C</td>",'<td class="catcher">C</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>P</td>",'<td class="pitcher">P</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>LF</td>",'<td>LF</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>CF</td>",'<td>CF</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>RF</td>",'<td>RF</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineupTable = $HTMLLineupTable -replace "<td>X</td>",'<td class="bench">bullpen</td><td class="hitresult"> 1B </br> 2B </br> 3B </br> HR </br> BB </br> O</span></td>'
$HTMLLineup = @"
<div id="game-lineup">
<h2>Lineup</h2>
$HTMLLineupTable
</div>
"@
$HTMLLineup
}

Function New-LastOut {
  [Cmdletbinding()]
    param ()
$LastOut = @"
<p>Last Out</p>
"@
$LastOut
}

Function New-LastOutAlternative {
  [Cmdletbinding()]
    param ()
$LastOut = @"
<div id="lastout">
<table>
<tr><th></th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th></tr>
<tr><td>Last Out</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
</table>
</div>
"@
$LastOut
}

Function Set-HTML {
[cmdletbinding()]
param (
    [parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)]
    $GameDetail = $null
)
$css = $GameDetail.css 
$Teamname = $GameDetail.Teamname
$GameInfo = $GameDetail.GameInfo
$DugoutJobs = $GameDetail.DugoutJobs
$NewLineup = $GameDetail.NewLineup
$TeamDir = $GameDetail.TeamDir

$HTMLHead = New-HTMLHead -css (Get-CSS -Path $css) -HTMLTitle "LineUp"
$HTMLHeader = New-HTMLHeader -HTMLHeaderTitle (New-HTMLHeaderTitle -headerone $TeamName)
$HTMLEnd = New-HTMLEnd 

$HTMLGameDay = New-HTMLGameDay -GameInfo $GameInfo
$HTMLRuns = New-HTMLRuns -GameInfo $GameInfo

$HTMLDugOutWhileBatting = New-HTMLDugOutWhileBatting -DugoutJobs $DugoutJobs
$HTMLDugOutWhilefielding = New-HTMLDugOutWhilefielding -DugoutJobs $DugoutJobs
$parameters = @{
    HTMLDugOutWhileBatting = $HTMLDugOutWhileBatting
    HTMLDugOutWhilefielding = $HTMLDugOutWhilefielding
}
$HTMLDugOutDuties = New-HTMLDugOutDuties @parameters

$HTMLLineup = New-HTMLLineup -NewLineup $NewLineup
$LastOut = New-LastOut

$DateName = $GameInfo.GameDate
$Name = $TeamDir + "\" + $TeamName + "_Lineup_$DateName.html"
$HTML = $HTMLHead
$HTML += $HTMLHeader
$HTML += $HTMLRuns
$HTML += $HTMLGameDay
$HTML += $HTMLLineup
#$HTML += $HTMLDugOutDuties
$HTML += $HTMLEnd
$HTML | Out-File -FilePath $Name
#start-process chrome.exe -argumentlist 
Start-Process $Name
}