$global:projectDirectory = "$env:OneDrive\Documents\Baseball\BaseballLineupGenerator"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:Rosterxml = "$testTeamDir\data\roster.xml"

Describe "Roster XML Content Validation" {
    BeforeAll {
        $global:xml = Select-Xml -Path $Rosterxml -XPath '//team'
    }

    Context "XML Structure" {
        It "Should have the 'team' element" {
            $xml | Should -Not -BeNullOrEmpty
        }
    
        It "Should have 'members' element inside 'team'" {
            $xml.Node.members | Should -Not -BeNullOrEmpty
        }
    
        It "Should have at least one 'member' element" {
            $xml.Node.members.member | Should -BeOfType System.Xml.XmlElement
        }
    }

    Context "Member Elements" { 
        It "Should have 'Name', 'Available', 'Jersey' elements for each member" {
            $xml.Node.members.member | ForEach-Object {
                $_.Name | Should -Not -BeNullOrEmpty
                $_.Available | Should -Not -BeNullOrEmpty
                $_.Jersey | Should -Not -BeNullOrEmpty
            }
        }
    }
}
