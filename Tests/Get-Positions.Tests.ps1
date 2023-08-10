$global:projectDirectory = Join-Path $PSScriptRoot "..\"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:PositionsXML = "$testTeamDir\data\positions.xml"
Describe "Positions XML Content Validation" {
    BeforeAll {
        $global:xmlPositions = Select-Xml -Path $PositionsXML -XPath '//team'
    }

    Context "XML Structure" {
        It "Should have the 'team' element" {
            $xmlPositions | Should -Not -BeNullOrEmpty
        }
    
        It "Should have 'members' element inside 'team'" {
            $xmlPositions.Node.positions | Should -Not -BeNullOrEmpty
        }
    
        It "Should have at least one 'member' element" {
            $xmlPositions.Node.positions.assignment | Should -BeOfType System.Xml.XmlElement
        }
    }
}