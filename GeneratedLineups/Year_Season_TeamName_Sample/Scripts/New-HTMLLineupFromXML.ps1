<#
.Synopsis 
    A PowerShell helper script for generating game details.
.Description	
    This script generates game details using the New-HTMLGameDetailFromXML.ps1 script.
.Parameter 
    None
.Example
    .\Invoke-GameDetailScript.ps1
.Notes
    Author: Jason Gebhart
    Version: 1.3
    Last Modified: August 8, 2023
#>
[cmdletbinding()]
param ()

# Move up two levels to reach the GeneratedLineups directory
# Get the path of the GeneratedLineups directory without changing the current directory
$generatedLineupsPath = Convert-Path ..\..\
$teamdir = Split-Path $PSScriptRoot -Parent
$projectDirectory = Split-Path $generatedLineupsPath -Parent
# Display verbose messages for clarity
Write-Verbose "[$($MyInvocation.MyCommand)] - generatedLineupsPath: $generatedLineupsPath"
Write-Verbose "[$($MyInvocation.MyCommand)] - teamdir: $teamdir"
# Define paths to script and XML file

$gameDetailScriptPath = Join-Path $projectDirectory 'Scripts\\New-HTMLGameDetailFromXML.ps1'
$xmlFilePath = Join-Path -Path $teamdir -ChildPath 'Lineup.xml'

# Check if the required script and folder exist
if (Test-Path -Path $gameDetailScriptPath -PathType Leaf) {
    # Check if the XML file exists
    if (Test-Path -Path $xmlFilePath -PathType Leaf) {
        # Execute New-HTMLGameDetailFromXML.ps1 with parameters
        & $gameDetailScriptPath -TeamPath $teamdir -Verbose
    } else {
        Write-Error "The XML file ($xmlFilePath) does not exist."
    }
} else {
    Write-Error "Required script or folder does not exist."
}