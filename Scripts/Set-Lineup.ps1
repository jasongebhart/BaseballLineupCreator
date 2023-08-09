<#
.SYNOPSIS 
Automated Baseball Lineup Generator.

.DESCRIPTION
This script generates an automated baseball lineup based on various factors like player availability, positions, and more. It loads player and team data from XML files and generates a lineup for a specific number of innings using different lineup methods.

.PARAMETER TeamDir
The directory containing the XML files with team and player information. If not provided, it will default to a sample directory structure.

.PARAMETER NumberOfInnings
The number of innings to generate the lineup for. Default value is 5.

.PARAMETER LineupMethod
The lineup method to be used. Available options are 'Random', 'TotalValue', 'Bench', and 'Assigned'. The default value is 'TotalValue'.

.EXAMPLE
.\Generate-BaseballLineup.ps1 -TeamDir "C:\BaseballTeam\TeamX" -NumberOfInnings 6 -LineupMethod "TotalValue"

This example generates a baseball lineup for the team located at "C:\BaseballTeam\TeamX" for 6 innings using the 'TotalValue' lineup method.

.NOTES
Author: Jason Gebhart
#>
[cmdletbinding()]
param (
[parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)]
$TeamDir = $null,
[parameter(Position=1,Mandatory=$false,ValueFromPipeline=$true)]
$NumberOfInnings = 6,
[parameter(Position=2,Mandatory=$false,ValueFromPipeline=$true)]
[ValidateSet('Random','TotalValue','Bench','Assigned')]
$LineupMethod = 'TotalValue'
)
# Set the script's root directory to the current directory if $PSScriptRoot is null
$ScriptRoot = if ($null -ne $PSScriptRoot) { $PSScriptRoot } else { ".\" }

# Rest of the code remains the same
#Set-Location $ScriptRoot 
Get-Module BaseballLineup | Remove-Module
Get-Module HTMLBaseballLineup | Remove-Module
Import-Module -Name "$ScriptRoot\..\Modules\BaseballLineup" -Verbose -Global -Force -ErrorAction Stop
Import-Module -Name "$ScriptRoot\..\Modules\HTMLBaseballLineup" -Verbose -Global -Force -ErrorAction Stop

If (-not($TeamDir)){
    $TeamDir = "$(Split-Path $ScriptRoot -Parent)\Year_Season_TeamName_Sample"
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - team $TeamDir" 
}

$Rosterxml = "$TeamDir\Data\roster.xml"
$PitcherXML = "$TeamDir\Data\pitchers.xml"
$PositionXML = "$TeamDir\Data\positions.xml"
$schedulecsv= "$TeamDir\Data\schedule.csv"
$dugoutxml = "$TeamDir\Data\dugout.xml"
$css = "$ScriptRoot\..\Styles\style.css"
$BaseballPositionsJSON = "$TeamDir\Data\baseball.config.json"

$BaseballPositions = Get-BaseballConfig -Baseballconfig $BaseballPositionsJSON
[XML]$Roster = Get-Content -Path $Rosterxml
$TeamName = $Roster.team.friendlyname

$CustomPositions = Foreach ($player in New-PositionFromXML -XMLPath $PositionXML -ea stop) {
    If ($player.Position -ne "Pitcher"){
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $($player.name), Inning  $($player.inning), Position $($player.position)"
        [pscustomobject] @{
            Name = $player.name
            Inning = $player.inning
            Position = $player.position
        }
    }
}
Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Total Custom Positions $($CustomPositions.count)"
# TeamMembers is used later in the script
$TeamMembers = New-TeamMemberFromXML -XMLPath $Rosterxml
($TeamMembersList = Foreach ($member in $TeamMembers) {
    If ($member.Available -eq "yes"){
        $member.Name
    }
} ) | Sort-Object {Get-Random}

# Count Active Players
$TotalActivePlayers = $TeamMembersList.Count
Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Total Team Members available $TotalActivePlayers"
     
$Pitchers = Foreach ($player in New-PitcherFromXML -xml $PitcherXML) {
    If ($player.Position -eq "Pitcher"){
        [pscustomobject] @{
            Name = $player.Name
            Inning = $player.Inning
            Position = $player.position
        }
    }
}
Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Total Pitcher Innings Assigned: $($Pitchers.count)"

If ($Pitchers.count -lt $NumberOfInnings){
    Write-Warning -Message 'No Pitchers Defined - creating randomly'
    $Pitchers = New-PitcherFromRandom -TeamMembersList $TeamMembersList -NumberOfInnings $NumberOfInnings
}

# Use an array to store bench players
$BenchPlayers = @($false, $false, $false, $false)

$Innings = New-Innings -BaseballPositions $BaseballPositions -NumberOfInnings $NumberOfInnings
$NonPitchers = Get-NonPitchers -TeamMembers $TeamMembersList -Pitchers $Pitchers | Sort-Object {Get-Random}

Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Define the number of Bench Players"
Switch ($TotalActivePlayers) {
    {$_ -le 9} {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No Bench Players"
        }
    (10) {
        $BenchPlayers[0] = $true
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - One Bench Player"
    }
    (11) {
        $BenchPlayers[0] = $true
        $BenchPlayers[1] = $true
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Two Bench Players"
    }
    (12) {
        $BenchPlayers[0] = $true
        $BenchPlayers[1] = $true
        $BenchPlayers[2] = $true
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Three Bench Players"
    }
    (13) {
        $BenchPlayers[0] = $true
        $BenchPlayers[1] = $true
        $BenchPlayers[2] = $true
        $BenchPlayers[3] = $true
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Four Bench Players"
    }
    default {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Unknown amount of Bench Players"
        $BenchPlayers = @($false, $false, $false, $false)
        }
}

If ($BenchPlayers[0]) {
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - There is at least one bench player"
    If (($Pitchers | Select-Object -Property Name -unique).Count -lt $NumberOfInnings) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Pitchers are pitching more than one inning"
    } else {
        $Innings = Set-BenchOne -Innings $Innings -Pitchers $Pitchers -NonPitchers $NonPitchers -TotalActivePlayers $TotalActivePlayers -verbose
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Pitchers are pitching just one inning"
    }
}

For ($i = 1; $i -lt ($NumberOfInnings+1); $i++)
{ 
    If ($Pitchers) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set Pitchers"
        $Innings = Set-CustomPosition -Innings $Innings -CustomPositions $Pitchers -TargetInning $i -verbose
    }
    If ($CustomPositions) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set Custom Positions"
        $Innings = Set-CustomPosition -Innings $Innings -CustomPositions $CustomPositions -TargetInning $i -verbose
    }
}

# Do not run for last inning
For ($i = 1; $i -lt ($NumberOfInnings); $i++)
{ 
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set Inning $i"
    # Set Bench Players based on the inning
    if ($BenchPlayers[0]) {
        if ($i -ne 2) {
            if (($Pitchers | Select-Object -Property Name -Unique).Count -lt $NumberOfInnings) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Pitchers are pitching more than one inning"
                $Innings = Set-Bench -Name "Bench One" -Innings $Innings -TeamMembers $TeamMembersList -Start $i -End $i -Verbose 
            } 
        } else {
            if (($Pitchers | Select-Object -Property Name -Unique).Count -lt $NumberOfInnings) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Pitchers are pitching more than one inning"
                $Innings = Set-Bench -Name "Bench Two" -Innings $Innings -TeamMembers $TeamMembersList -Start $i -End $i -Verbose 
            } else {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Setting Bench two for inning 2"
                $Innings = Set-BenchTwoInningTwo -Innings $Innings -Pitchers $Pitchers -NonPitchers $NonPitchers -Verbose  
            }
        }
    }

    if ($BenchPlayers[1] -and $i -ne 2) {
        $Innings = Set-Bench -Name "Bench Two" -Innings $Innings -TeamMembers $TeamMembersList -Start $i -End $i -Verbose 
    }

    if ($BenchPlayers[2]) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set Bench Three"
        $Innings = Set-Bench -Name "Bench Three" -Innings $Innings -TeamMembers $TeamMembersList -Start $i -End $i -Verbose
    } 
    
    if ($BenchPlayers[3]) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set Bench Four"
        $Innings = Set-Bench -Name "Bench Four" -Innings $Innings -TeamMembers $TeamMembersList -Start $i -End $i -Verbose
    }

    # Set the inning details based on the inning number
    if ($i -gt 1) {
        $Innings = Set-CoreLateInnings -Innings $Innings -TeamMembers $TeamMembersList -Inning $i -Verbose              
    } else {
        $Innings = Set-FirstInning -TeamMembers $TeamMembersList -Innings $Innings -Verbose
    }
}
$benchNames = @('One', 'Two', 'Three', 'Four')
$benchplayertrue = $BenchPlayers | Where-Object {$_ -eq $true}
Write-Verbose -Message "[$($MyInvocation.MyCommand)] Count of Benchplayers $($benchplayertrue.Count)"
for ($i = 0; $i -lt $benchplayertrue.Count; $i++) {
    if ($BenchPlayers[$i]) {
        $benchName = "Bench " + $benchNames[$i]
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set $benchName"
        $Innings = Set-Bench -name $benchName -Innings $Innings -TeamMembers $TeamMembersList -Start $NumberOfInnings -end $NumberOfInnings -verbose 
    }
}

Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Setting last inning"
$Innings = Set-CoreLateInnings -Innings $Innings -TeamMembers $TeamMembersList -Inning $NumberOfInnings -verbose 

Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Checking for Next Game"
$Date = Get-Date 
$GameInfo = Get-GameInfoFromCSV -Date $Date.ToShortDateString() -ScheduleCsv $schedulecsv -RosterXml $Rosterxml -verbose
$DugoutJobs = New-JobFromXML -XMLPath $dugoutxml

Get-BenchPlayer -TeamMembers $TeamMembersList -Innings $Innings

$TotalValue = Get-PlayerTotalPositionValue -TeamMembers $TeamMembersList -Innings $Innings -verbose 
$TotalValue | Sort-Object -Property TotalPositionValue | Format-Table *

$BaseballPositions | Sort-Object -Property Value
# Set Lineup
Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Lineup Method: $LineupMethod"
$parameters = @{
    TeamMembers = $TeamMembers
    Innings = $Innings 
    TotalValue = $TotalValue 
    NumberOfInnings = $NumberOfInnings 
    LineupMethod = $LineupMethod
}
$NewLineup = Get-Lineup @parameters -verbose

$GameDetail = @{
    css = $css 
    Teamname = $Teamname
    GameInfo = $GameInfo
    DugoutJobs = $DugoutJobs
    NewLineup = $NewLineup
    TeamDir = $TeamDir
}

# Complex XML
Export-Clixml -Path ("$TeamDir" + "\Lineup.xml") -InputObject $GameDetail
Set-HTML -GameDetail $GameDetail