$global:projectDirectory = "$env:OneDrive\Documents\Baseball\BaseballLineupGenerator"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:PitcherXML = "$testTeamDir\data\pitchers.xml"
Describe "Pitcher XML Content Validation" {
    BeforeAll {
        $global:xml = Select-Xml -Path $PitcherXML -XPath '//team'
    }

    Context "XML Structure" {
        It "Should have the 'team' element" {
            $xml | Should -Not -BeNullOrEmpty
        }
    
        It "Should have 'members' element inside 'team'" {
            $xml.Node.pitchers | Should -Not -BeNullOrEmpty
        }
    
        It "Should have at least one 'member' element" {
            $xml.Node.pitchers.pitcher | Should -BeOfType System.Xml.XmlElement
        }
    }

    Context "Member Elements" { 
        It "Should have 'Name', 'Available', 'Jersey' elements for each member" {
            $xml.Node.pitchers.pitcher | ForEach-Object {
                $_.Name | Should -Not -BeNullOrEmpty
                $_.Inning | Should -Not -BeNullOrEmpty
                $_.Position | Should -Not -BeNullOrEmpty
            }
        }
    }
}
