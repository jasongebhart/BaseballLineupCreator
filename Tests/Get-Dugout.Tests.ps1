$global:projectDirectory = Join-Path $PSScriptRoot "..\"
Import-Module -Name "$projectDirectory\Modules\BaseballLineup" -verbose
$global:testTeamDir = "$projectDirectory\GeneratedLineups\Year_Season_TeamName_Sample"
$global:DugoutXML = "$testTeamDir\Data\dugout.xml"

Describe "Dugout XML Content Validation" {
    BeforeAll {
        $global:XMLDugout = Select-Xml -Path $DugoutXML -XPath '//dugout'
    }

    Context "XML Structure" {
        It "Should have the 'dugout' element" {
            $XMLDugout | Should -Not -BeNullOrEmpty
        }
    
        It "Should have 'jobs' element inside 'dugout'" {
            $XMLDugout.Node.jobs | Should -Not -BeNullOrEmpty
        }
    
    }
}