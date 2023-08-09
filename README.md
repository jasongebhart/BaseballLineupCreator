# Baseball Lineup Generator

## Project Structure

- `Baseball_code/`: The project code container.
  - `Set-Lineup.ps1`: Control file for setting the lineup.
  - `New-HTMLGameDetailFromXML.ps1`: Control file for generating HTML game details from XML data.
  - `style.css`: CSS file for styling the HTML output.

- `baseball/`: Module folder for the baseball module.
  - `baseball.psd1`
  - `Baseball.psm1`

- `HTMLBaseball/`: Module folder for the HTMLBaseball module.
  - `HTMLBaseball.psm1`

- `Tests/`: Folder for Pester tests.
  - `Get-BaseballConfig.Tests.ps1`: Test file for the `Get-BaseballConfig` function.
  - `Get-Dugout.Tests.ps1`: Test file for the `Get-Dugout` function.
  - `Get-GameInfoFromCSV.Tests.ps1`: Test file for the `Get-GameInfoFromCSV` function.
  - `Get-PitcherOfInning.Tests.ps1`: Test file for the `Get-PitcherOfInning` function.
  - `Get-Pitchers.Tests.ps1`: Test file for the `Get-Pitchers` function.
  - `Get-Positions.Tests.ps1`: Test file for the `Get-Positions` function.
  - `Get-Roster.Tests.ps1`: Test file for the `Get-Roster` function.

- `Year_Season_TeamName/`: Location for your customized code.
  - **Data**
    - `baseball.config.json`: Configuration file for baseball.
    - `dugout.xml`: XML file containing dugout information.
    - `Lineup - Copy.xml`: Copy of the lineup XML file.
    - `Lineup.xml`: XML file containing lineup information.
    - `pitchers.xml`: XML file containing information about pitchers.
    - `positions.xml`: XML file containing information about player positions.
    - `roster.xml`: XML file containing the team roster.
    - `schedule.csv`: CSV file containing the schedule.

  - **Scripts**
    - `GetLineup.lnk`: Shortcut link to the GetLineup script.
    - `New-Lineup_Launcher.ps1`: PowerShell script for launching the New Lineup.
    - `Print-ToHTMLLineup.lnk`: Shortcut link to the script for printing lineup to HTML.
    - `Set-Lineup_Launcher.ps1`: PowerShell script for launching the Set Lineup.

## Description

This project contains a collection of PowerShell scripts and modules related to baseball management and generating HTML game details. The project is structured as follows:

- The `Baseball_code/` directory holds the main control files for setting the lineup and generating HTML game details.

- The `baseball/` folder contains the PowerShell module for managing baseball-related functionalities.

- The `HTMLBaseball/` folder contains the PowerShell module for generating HTML output related to baseball games.

- The `Tests/` directory includes the Pester tests for validating the functionality of the modules.

Feel free to explore the individual folders and files to learn more about the specific functionalities of each component.

# Baseball Functions

## Get-BaseballConfig

Reads and parses the Baseball Configuration file.

## Get-BenchPlayer

Retrieves the count of bench appearances for each player in a baseball team.

## Get-GameInfoFromCSV

Retrieves game information from a CSV schedule file and XML roster file for a specific target date.

## Get-Lineup

Retrieve the baseball lineup based on the provided team members and innings data.

## Get-LineupNEWCode

Generates a baseball lineup based on the provided team members and innings data.

## Get-NonPitchers

Retrieves the non-pitchers from the given list of team members and pitchers.

## Get-PitcherOfInning

Retrieves the pitcher for a specific inning from a collection of innings.

## Get-PlayerAssignedPosition

Get the assigned position for a player from a list of possible positions.

## Get-PlayerAvailableForInning

Retrieve players available for a specific inning.

## Get-PlayerDiscovery

Compares two objects and returns the differences found in the second object.

## Get-PlayerPosition

Retrieves the position of a player in a baseball team based on the provided player name and innings data.

## Get-PlayerPositionValueInInning

Retrieves the position and position value of a player in a specific inning.

## Get-PlayerTotalPositionValue

Calculates the total position value for each player in a baseball team.

## Get-PositionAbbreviation

Gets the abbreviation for a baseball position.

## New-Innings

Creates a collection of innings with specified baseball positions.

## New-JobFromXML

Creates job objects from an XML file.

## New-PitcherFromRandom

Generates a collection of pitchers from a randomized list of team members for multiple innings.

## New-PitcherFromXML

Creates pitcher objects from an XML file.

## New-PitcherList

Creates a list of pitcher names.

## New-PositionFromXML

Creates position objects from an XML file.

## New-TeamMemberFromXML

Creates team member objects from an XML file.

## Set-Bench

Sets bench players for multiple innings based on player availability and bench counts.

## Set-BenchByTotalValue

Sets the Bench Three player for each inning based on the provided criteria.

## Set-BenchOne

Sets the Bench One player for each inning based on the provided pitchers and non-pitchers.

## Set-BenchTwoInningTwo

Assigns a player from the first inning's pitchers to the second inning's Bench Two position.

## Set-CoreLateInnings

Assigns players to the fielding positions in the core late innings.

## Set-CustomPosition

Sets custom positions for players in specific innings.

## Set-FirstInning

Assigns players to positions for the first inning.

## Set-InfieldFieldPositions

Assigns players to infield positions based on their usage in previous innings.

## Set-Jersey

Sets jersey numbers for players in the innings based on the provided team members.

## Set-OutField

Assigns players to outfield positions based on their usage in previous innings.

## Set-PlayerPosition

Assigns a player to a specified position in the infield.

## Set-PlayerPositionOutfielder

Assigns a player to an outfielder position in a baseball team.

## Set-UnassignedPlayer

Checks for unassigned players in a specific inning and assigns them to the Bench One position.

## Test-PlayedPosition

Checks if a player has already played a specific position.
