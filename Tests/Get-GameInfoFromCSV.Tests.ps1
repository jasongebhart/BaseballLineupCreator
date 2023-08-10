Describe "Get-GameInfoFromCSV" {
    BeforeAll {
        $global:projectDirectory = "$env:OneDrive\Documents\Baseball\BaseballLineupGenerator"
        Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
        $global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
        #$global:Rosterxml = "$testTeamDir\roster.xml"
        #$global:scheduleCsv = "$testTeamDir\schedule.csv"
        #$global:targetDate = Get-Date "2023-08-01"

        # Create temporary XML and CSV files for testing
        $tempXmlContent = @"
<team name="Year_Season_TeamName_Sample" friendlyname="Sample Name">
    <members>
        <member>
            <Name>Jack</Name>
            <Available>yes</Available>
            <Jersey>7</Jersey>
            <Batting>1</Batting>
            <Fielding></Fielding>
        </member>
    </members>
</team>
"@
        $tempCsvContent = @"
Date,Day,Start Time,End Time,Location,Home,Visitor
09/11/2022,Sunday,11:30 AM,2:30 PM,The Yard,Sample Name, Gold
11/06/2022,Sunday,11:30 AM,2:30 PM,Field Of Dreams,Cardinal ,Sample Name
11/05/2023,Sunday,11:30 AM,2:30 PM,The Yard,Sample Name, Black
"@

        $tempXmlPath = New-TemporaryFile
        $tempCsvPath = New-TemporaryFile

        Set-Content -Path $tempXmlPath -Value $tempXmlContent
        Set-Content -Path $tempCsvPath -Value $tempCsvContent

        $global:Rosterxml = $tempXmlPath
        $global:scheduleCsv = $tempCsvPath
    }

    AfterAll {
        # Clean up temporary files
        Remove-Item $global:Rosterxml
        Remove-Item $global:scheduleCsv
    }
    
    Context "When valid input is provided" {
        It "Should retrieve the correct game info for the next game" {
            # Invoke the function
            $gameInfo = Get-GameInfoFromCSV -TargetDate "08/02/2023" -ScheduleCsv $scheduleCsv -RosterXml $rosterXml

            # Assertions
            $gameInfo.Location | Should -Be "The Yard"
            $gameInfo.StartTime | Should -Be "11:30 AM"
            $gameInfo.GameDate | Should -Be "11-05-2023"
            $gameInfo.HomeTeam | Should -Be "Sample Name"
            $gameInfo.AwayTeam | Should -Be "Black"
        }
    }

    Context "When there are no future games after the target date" {
        It "Should display a warning and return nothing" {
            # Invoke the function
            $gameInfo = Get-GameInfoFromCSV -TargetDate "08/07/2029" -ScheduleCsv $scheduleCsv -RosterXml $rosterXml

            # Assertions
            $gameInfo | Should -BeNullOrEmpty
        }
    }
}
