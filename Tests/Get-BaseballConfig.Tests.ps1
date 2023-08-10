# Assuming you have imported the module or sourced the functions
$global:projectDirectory = Join-Path $PSScriptRoot "..\"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
#$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$BaseballConfig = Get-BaseballConfig -Baseballconfig "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample\Data\baseball.config.json" -verbose
Describe "baseball module tests" {

    # Test Get-BaseballConfig function
    Context 'Get-BaseballConfig function' {
        It 'Should contain 13 objects' {
            $BaseballConfig.Count | Should -Be 13
        }
        It "Should have the expected properties for each object" {
            $expectedProperties = @("Name", "Value", "Frequency", "Number")
            $BaseballConfig | ForEach-Object {
                $_.PSObject.Properties.Name | Should -Be $expectedProperties
            }
        }
        It "Should have 'Value' property as a number" {
            $BaseballConfig | ForEach-Object {
                $value = $_.Value
                $isNumber = [double]::TryParse($value, [ref]$null) -or [int]::TryParse($value, [ref]$null)
                $isNumber | Should -Be $true
            }
        }
        It "Should have 'Frequency' property as a number" {
            $BaseballConfig | ForEach-Object {
                $frequency = $_.Frequency -as [int]
                $frequency -and $frequency -eq $_.Frequency | Should -Be $true
            }
        }  
        It "Should have correct values for 'Number' property" {
            $BaseballConfig | ForEach-Object {
                $number = $_.Number -as [int]
                $number | Should -BeOfType [System.Int32]
            }
        }
        It "Should have valid positions defined" {   
            # Extract the "Name" property from each object in the array
            $positionNames = $BaseballConfig | ForEach-Object { $_.Name }
        
            # Now check if the specific position names exist in the $positionNames array
            $positionNames | Should -Contain "First Base"
            $positionNames | Should -Contain "Second Base"
            # Add more position names for validation
        }  
    }
}
