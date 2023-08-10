$global:projectDirectory = "$env:OneDrive\Documents\Baseball\BaseballLineupGenerator"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:TeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:Rosterxml = "$TeamDir\data\roster.xml"
$global:PitcherXML = "$TeamDir\Data\pitchers.xml"
$global:PositionXML = "$TeamDir\Data\positions.xml"
$global:schedulecsv= "$TeamDir\Data\schedule.csv"
$global:dugoutxml = "$TeamDir\Data\dugout.xml"
$global:css = "$PSScriptRoot\style.css"
$global:BaseballPositionsJSON = "$TeamDir\Data\baseball.config.json"

Describe "Set-BenchOne" {
    BeforeAll {
        # Test data setup
        $global:Sixinnings = 1..6 | ForEach-Object {
            $playerData = @(
                [PSCustomObject]@{ Player = 'Player1'; Position = "Pitcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 1 },
                [PSCustomObject]@{ Player = 'Player2'; Position = "Catcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 2 },
                [PSCustomObject]@{ Player = 'Player3'; Position = "First Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 3 },
                [PSCustomObject]@{ Player = 'Player4'; Position = "Second Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 4 },
                [PSCustomObject]@{ Player = 'Player5'; Position = "Third Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 5 },
                [PSCustomObject]@{ Player = 'Player6'; Position = "Short Stop"; Inning = $_; PositionValue = 1.0; PositionNumber = 6 },
                [PSCustomObject]@{ Player = 'Player7'; Position = "Left Field"; Inning = $_; PositionValue = 1.0; PositionNumber = 7 },
                [PSCustomObject]@{ Player = 'Player8'; Position = "Center Field"; Inning = $_; PositionValue = 1.2; PositionNumber = 8 },
                [PSCustomObject]@{ Player = 'Player9'; Position = "Right Field"; Inning = $_; PositionValue = 0.9; PositionNumber = 9 },
                [PSCustomObject]@{ Player = 'Player10'; Position = "Center Field"; Inning = $_; PositionValue = 1.2; PositionNumber = 8 }
            )
            $playerData
        }
        <#
        $global:SixinningsInitialize = @(1..6 | ForEach-Object {
            [PSCustomObject]@{
                Player = $null;
                Position = $null;
                Inning = $_;
                PositionValue = $null;
                PositionNumber = $null;
                Jersey = $null
            }
        })
        $innings = @(
            [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0 },
            [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0 },
            [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0 },
            [PSCustomObject]@{ Inning = "6"; Player = $null; Position = "Bench One"; PositionValue = 0 },
            [PSCustomObject]@{ Inning = "x4"; Player = $null; Position = "Bench One"; PositionValue = 0 },
            [PSCustomObject]@{ Inning = "x"; Player = $null; Position = "Bench One"; PositionValue = 0 }
        )
        $global:pitchers = @(
            [PSCustomObject]@{ Name = "Player1"; Inning = 1; Position = "Pitcher"},
            [PSCustomObject]@{ Name = "Player2"; Inning = 2; Position = "Pitcher"},
            [PSCustomObject]@{ Name = "Player3"; Inning = 3; Position = "Pitcher"},
            [PSCustomObject]@{ Name = "Player4"; Inning = 4; Position = "Pitcher"},
            [PSCustomObject]@{ Name = "Player5"; Inning = 5; Position = "Pitcher"},
            [PSCustomObject]@{ Name = "Player6"; Inning = 6; Position = "Pitcher"}
        )
        $global:nonPitchers = @("Player7", "Player8", "Player9", "Player10", "Player11")
        #>
        $global:BaseballPositions = Get-BaseballConfig -Baseballconfig $BaseballPositionsJSON
        $ActivePitchers = New-PitcherFromXML -xml $PitcherXML
        $global:Pitchers = Foreach ($player in $ActivePitchers) {
            If ($player.Position -eq "Pitcher"){
                [pscustomobject] @{
                    Name = $player.Name
                    Inning = $player.Inning
                    Position = $player.position
                }
            }
        }
        $TeamMembersList = Foreach ($member in New-TeamMemberFromXML -XMLPath $Rosterxml) {
            If ($member.Available -eq "yes"){
                $member.Name
            }
        }    
        $global:TeamMembersList = $TeamMembersList | Sort-Object {Get-Random}
        $global:NonPitchers = Get-NonPitchers -TeamMembers $TeamMembersList -Pitchers $Pitchers | Sort-Object {Get-Random}
    }

    Context "When setting Bench One for inning 6 with 10 total active players" {
        It "Should assign the first pitcher to the last Bench spot" {
            # Invoke the function
            $NumberOfInnings = 6
            $Innings = New-Innings -BaseballPositions $BaseballPositions -NumberOfInnings $NumberOfInnings
            $Innings = Set-BenchOne -Innings $Innings -Pitchers $Pitchers -NonPitchers $nonPitchers -TotalActivePlayers 10
            $NumberOfInnings = 6
            For ($i = 1; $i -lt ($NumberOfInnings+1); $i++){
                $Innings = Set-CustomPosition -Innings $Innings -CustomPositions $Pitchers -TargetInning $i -verbose
            }
            $inning6BenchOne = $innings | Where-Object { $_.Inning -eq 6 -and $_.Position -eq "Bench One" }
            # Assertions
            $inning6BenchOne.Player | Should -Be $Pitchers[0].Name
        }
    }
<#
    Context "When setting Bench One for inning 'x'" {
        It "Should assign a non-pitcher player with the least total position value" {
            # Invoke the function
            $result = Set-BenchOne -Innings $innings -Pitchers $pitchers -NonPitchers $nonPitchers

            # Assertions
            $result[8].Player | Should -BeIn $nonPitchers
        }
    }

    Context "When setting Bench One for other innings" {
        It "Should assign the pitcher for the next inning" {
            # Invoke the function
            $result = Set-BenchOne -Innings $innings -Pitchers $pitchers -NonPitchers $nonPitchers

            # Assertions
            $result[0].Player | Should Be "Player2"
            $result[1].Player | Should Be "Player3"
            $result[2].Player | Should BeNullOrEmpty
            $result[3].Player | Should BeNullOrEmpty
            $result[4].Player | Should BeNullOrEmpty
            $result[6].Player | Should BeNullOrEmpty
            $result[7].Player | Should BeNullOrEmpty
        }
    }
   #> 
}
