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
# Move up two levels to reach the GeneratedLineups directory
# Get the path of the GeneratedLineups directory without changing the current directory
$generatedLineupsPath = Convert-Path ..\..\
$teamdir = Split-Path $PSScriptRoot -Parent
$projectDirectory = Split-Path $generatedLineupsPath -Parent
# Display verbose messages for clarity
Write-Verbose "[$($MyInvocation.MyCommand)] - generatedLineupsPath: $generatedLineupsPath"
Write-Verbose "[$($MyInvocation.MyCommand)] - teamdir: $teamdir"

$parameters = @{
    teamdir = $teamdir
    NumberOfInnings = 6
    LineupMethod = 'Random' # Valid values: 'Random', 'TotalValue', 'Bench', 'Assigned'
}

$lineupScriptPath = Join-Path $projectDirectory 'Scripts\Set-Lineup.ps1'
& $lineupScriptPath @parameters -verbose

Set-Location $teamdir