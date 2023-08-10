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

- The `Tests/` directory includes Pester tests designed to validate the functionality of these modules.

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


