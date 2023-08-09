<#
.Synopsis 
    A PowerShell helper script for game details.
.Description	
    This script generates game details using the New-HTMLGameDetailFromXML.ps1 script.
.Parameter 
    TeamPath - Path to lineup.xml
.Example
    .\Invoke-GameDetailScript.ps1 -TeamPath C:\Path\To\Team
.Notes
    Author: Jason Gebhart
    Version: 1.1
    Last Modified: August 8, 2023
#>
[cmdletbinding()]
param (
    [parameter(Position=0, Mandatory=$true)]
    $TeamPath
)
try {
    $ScriptRoot = if ($null -ne $PSScriptRoot) { $PSScriptRoot } else { ".\" }

    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - team path $TeamPath" 
    Set-Location $ScriptRoot 
    Get-Module Baseball -ErrorAction SilentlyContinue | Remove-Module
    Get-Module HTMLBaseball -ErrorAction SilentlyContinue | Remove-Module

    Import-Module -Name "$ScriptRoot\baseball" -Global -Force -ErrorAction Stop
    Import-Module -Name "$ScriptRoot\HTMLBaseball" -Global -Force -ErrorAction Stop

    Write-Verbose -Message "[$($MyInvocation.MyCommand)] Load the XML data using Get-Content and cast it to an XML document"
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] XML $TeamPath\Lineup.xml"
    $GameDetail = Import-Clixml -Path "$TeamPath\Lineup.xml"

    #$GameDetail = $xmlData.GameDetail
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] GameDetail - $GameDetail.css"

    Set-HTML -GameDetail $GameDetail
} catch {
    Write-Error "An error occurred: $_"
}
