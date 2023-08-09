<#
.Synopsis 
    A script to set up a baseball lineup.
.Description
    This script sets up a baseball lineup using the Set-Lineup.ps1 script.
.Parameter 
    None
.Example
    .\Invoke-BaseballLineup.ps1
.Notes
    Author: Jason Gebhart
    Version: 1.0
    Last Modified: August 8, 2023
#>
[cmdletbinding()]
param ()

$grandparentDirectory = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$teamdir = Split-Path $PSScriptRoot -Parent

$parameters = @{
    teamdir = $teamdir
    NumberOfInnings = 6
    LineupMethod = 'Random' # Valid values: 'Random', 'TotalValue', 'Bench', 'Assigned'
}

$lineupScriptPath = Join-Path $grandparentDirectory 'Baseball_Code\Set-Lineup.ps1'
& $lineupScriptPath @parameters -verbose

Set-Location $teamdir