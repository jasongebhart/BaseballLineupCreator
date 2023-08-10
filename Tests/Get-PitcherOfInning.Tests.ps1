$global:projectDirectory = Join-Path $PSScriptRoot "..\"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:PitcherXML = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample\Data\data\pitchers.xml"

Describe "Get-PitcherOfInning" {
    BeforeAll {
        $global:innings = 1..6 | ForEach-Object {
            $playerData = @(
                [PSCustomObject]@{ Player = 'Player 1'; Position = "Catcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 2 },
                [PSCustomObject]@{ Player = 'Player 2'; Position = "Pitcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 1 },
                [PSCustomObject]@{ Player = 'Player 3'; Position = "Left Field"; Inning = $_; PositionValue = 1.0; PositionNumber = 7 },
                [PSCustomObject]@{ Player = 'Player 4'; Position = "First Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 3 },
                [PSCustomObject]@{ Player = 'Player 5'; Position = "Second Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 4 },
                [PSCustomObject]@{ Player = 'Player 6'; Position = "Short Stop"; Inning = $_; PositionValue = 1.0; PositionNumber = 6 }
            )
            $playerData
        }
    }

    Context "When $Innings contains no pitcher for Inning 1" {
        It "Returns a warning for Inning 1" {
            $InningsNoPitcher= @(
                [PSCustomObject]@{ Player = 'Player 1'; Position = "Catcher"; Inning = 1; PositionValue = 1.7; PositionNumber = 2 },
                [PSCustomObject]@{ Player = 'Player 2'; Position = "Third Base"; Inning = 1; PositionValue = 1.7; PositionNumber = 1 },
                [PSCustomObject]@{ Player = 'Player 3'; Position = "Left Field"; Inning = 1; PositionValue = 1.0; PositionNumber = 7 },
                [PSCustomObject]@{ Player = 'Player 4'; Position = "First Base"; Inning = 1; PositionValue = 1.7; PositionNumber = 3 },
                [PSCustomObject]@{ Player = 'Player 5'; Position = "Second Base"; Inning = 1; PositionValue = 1.7; PositionNumber = 4 },
                [PSCustomObject]@{ Player = 'Player 6'; Position = "Short Stop"; Inning = 1; PositionValue = 1.0; PositionNumber = 6 }
            )
            $result = Get-PitcherOfInning -Innings $InningsNoPitcher -Inning 1
            $result | Should -BeNullOrEmpty
            $warning = Get-Content function:/Get-PitcherOfInning | Select-String "No pitcher found for inning"
            $warning | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When $Innings contains a pitcher for Inning 1' {
        It "Returns the pitcher for Inning 1" {
            $result = Get-PitcherOfInning -Innings $Innings -Inning 1
            $result | Should -Not -BeNullOrEmpty
            $result.Position | Should -Be "Pitcher"
            $result.Inning | Should -Be 1
        }

    }

    Context 'When $Innings contains pitchers for multiple innings' {
        It "Returns the correct pitcher for Inning 1" {
            $result = Get-PitcherOfInning -Innings $Innings -Inning 1
            $result | Should -Not -BeNullOrEmpty
            $result.Position | Should -Be "Pitcher"
            $result.Inning | Should -Be 1
        }

        It "Returns the correct pitcher for Inning 2" {
            $result = Get-PitcherOfInning -Innings $Innings -Inning 2
            $result | Should -Not -BeNullOrEmpty
            $result.Position | Should -Be "Pitcher"
            $result.Inning | Should -Be 2
        }

        It "Returns the correct pitcher for Inning 3" {
            $result = Get-PitcherOfInning -Innings $Innings -Inning 3
            $result | Should -Not -BeNullOrEmpty
            $result.Position | Should -Be "Pitcher"
            $result.Inning | Should -Be 3
        }
        It "Returns a warning for Inning 4 (not found)" {
            $InningVariable = 4
            $InningsNoPitcher= @(
                [PSCustomObject]@{ Player = 'Player 1'; Position = "Catcher"; Inning = $InningVariable; PositionValue = 1.7; PositionNumber = 2 },
                [PSCustomObject]@{ Player = 'Player 2'; Position = "Third Base"; Inning = $InningVariable; PositionValue = 1.7; PositionNumber = 1 },
                [PSCustomObject]@{ Player = 'Player 3'; Position = "Left Field"; Inning = $InningVariable; PositionValue = 1.0; PositionNumber = 7 },
                [PSCustomObject]@{ Player = 'Player 4'; Position = "First Base"; Inning = $InningVariable; PositionValue = 1.7; PositionNumber = 3 },
                [PSCustomObject]@{ Player = 'Player 5'; Position = "Second Base"; Inning = $InningVariable; PositionValue = 1.7; PositionNumber = 4 },
                [PSCustomObject]@{ Player = 'Player 6'; Position = "Short Stop"; Inning = $InningVariable; PositionValue = 1.0; PositionNumber = 6 }
            )
            $result = Get-PitcherOfInning -Innings $InningsNoPitcher -Inning 4
            $result | Should -BeNullOrEmpty
            $warning = Get-Content function:/Get-PitcherOfInning | Select-String "No pitcher found for inning"
            $warning | Should -Not -BeNullOrEmpty
        }
   }
    
}