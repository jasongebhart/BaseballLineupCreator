# Baseball Lineup Generator

# Project Structure

- `GeneratedLineups/`: Generated output directory for code results.
  - `Year_Season_TeamName/`: Customized code location.
    - `Data/`: Data files used for customization.
    - `Scripts/`: Scripts for launching various lineup tasks.

- `Modules/`: Contains PowerShell modules for baseball management.
  - `BaseballLineup/`: Module for managing baseball-related functionalities.
  - `HTMLBaseballLineup/`: Module for generating HTML output related to baseball games.

- `Scripts/`: Folder for helper scripts and control files.
- `Styles/`: Folder for CSS files used in HTML output.
- `Tests/`: Folder for Pester tests to validate module functionality.

Explore these folders to learn more about each component's role and functionality.

# Description

This project offers a collection of PowerShell scripts and modules designed to generate baseball lineups and game details in the form of an HTML web page, specifically designed for one-page printing. The project is structured as follows:

- The `Scripts/` directory houses the main control files for setting the lineup and generating HTML game details.

- The `BaseballLineup/` folder contains the PowerShell module responsible for managing baseball-related functionalities.

- The `HTMLBaseballLineup/` folder hosts the PowerShell module used to generate HTML output for baseball games.

The `Tests/` directory includes Pester tests designed to validate the functionality of these modules.

Feel free to delve into the individual folders and files to gain insights into the distinct functionalities of each component.

## Limitations
This project was designed for youth baseball. Therefore, the total number of innings is six. The script will not create more than 6 innings. 

## Getting Started

To use this project, follow these steps:

1. Clone the repository to your local machine.
2. Explore the project structure to familiarize yourself with the organization.
3. Copy the folder `GeneratedLineups/Year_Season_TeamName/` to `GeneratedLineups/your_team/`
3. Customize the data files in the `GeneratedLineups/your_team/data` directory for your specific needs.
    1. pitchers.xml
    2. roster.xml
    3. schedule.csv
4. The `Scripts` directory within `GeneratedLineups/your_team/` has a helper script (Invoke-NewBaseballLineup.ps1) that will launch the code and generate a lineup for you based off of the content you added to pitchers, roster, and schedule files. 
5. The lineup web page with be created here: `GeneratedLineups/your_team/``

For more detailed information about each function's usage and parameters, refer to the individual module folders and the respective function documentation.

Your explanation is clear and concise, but you could provide a bit more context and guidance. Here's a slightly expanded version with additional information:

**Modifying the Lineup**

There might be situations where you need to make adjustments to a generated lineup. Fortunately, this process is straightforward. Follow these steps to modify the lineup and generate an updated HTML representation:

1. Locate the `Lineup.xml` file: This file can be found in the `GeneratedLineups/your_team/` directory. It contains the current lineup data that you wish to modify.

2. Edit the `Lineup.xml` file: Open the `Lineup.xml` file using a text editor of your choice. Make the necessary changes to the lineup, such as reordering players or adjusting positions. Save the file after making your modifications.

3. Launch the `New-HTMLLineupFromXML.ps1` script: Navigate to the `Scripts` directory within `GeneratedLineups/your_team/`. Run the `New-HTMLLineupFromXML.ps1` PowerShell script. This script takes the modified `Lineup.xml` file as input and generates a new HTML file.

4. Check the generated HTML file: Once the script completes, you'll find a new HTML file representing the updated lineup. This HTML file will be located in the same `GeneratedLineups/your_team/` directory. You can open this HTML file in a web browser to view the changes you made.

By following these steps, you can easily customize and update the lineup to meet your specific needs. Experiment and make adjustments as necessary to create the desired lineup configuration.

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
