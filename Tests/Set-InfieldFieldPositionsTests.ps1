$global:projectDirectory = Join-Path $PSScriptRoot "..\"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:Rosterxml = "$testTeamDir\data\roster.xml"
$global:PitcherXML = "$testTeamDir\Data\pitchers.xml"
$global:PositionXML = "$testTeamDir\Data\positions.xml"
$global:schedulecsv= "$testTeamDir\Data\schedule.csv"
$global:dugoutxml = "$testTeamDir\Data\dugout.xml"
$global:css = "$PSScriptRoot\style.css"
$global:BaseballPositionsJSON = "$testTeamDir\Data\baseball.config.json"

Describe "Set-InfieldFieldPositions Function" {
    Context "With valid input data" {
        BeforeEach {
            # Create sample innings and playerUsage data
            $global:Innings = 1..2 | ForEach-Object {
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
            $playerUsage = @(
                [PSCustomObject]@{ Name = "Player1"; EligiblePositions = @("First Base", "Third Base"); PositionCount = 2 },
                [PSCustomObject]@{ Name = "Player2"; EligiblePositions = @("First Base", "Second Base", "Third Base"); PositionCount = 3 },
                [PSCustomObject]@{ Name = "Player3"; EligiblePositions = @("Second Base", "Third Base"); PositionCount = 2 },
                [PSCustomObject]@{ Name = "Player4"; EligiblePositions = @("Third Base"); PositionCount = 1 },
                [PSCustomObject]@{ Name = "Player5"; EligiblePositions = @("First Base"); PositionCount = 1 }
            )

            # Invoke the function and save the result
            $assignedInfielders = Set-InfieldFieldPositions -Innings $innings -PlayerUsage $playerUsage
        }

        It "Should return an array of assigned infielders" {
            $assignedInfielders | Should -BeOfType [System.Collections.ArrayList]
        }

        It "Should assign players to infield positions" {
            # Ensure each player in the result has a valid infield position assigned
            $assignedInfielders.ForEach{
                $_.Position | Should -BeIn "Catcher", "First Base", "Second Base", "Short Stop", "Third Base"
            }
        }

        # Add more specific tests based on your requirements...
    }
}