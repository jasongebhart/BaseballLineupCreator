<#
.Synopsis 

.Description


.Parameter 

.Example

.Notes
#>
#Functions
function Get-PlayerAvailableForInning {
    <#
    .SYNOPSIS
    Determine eligible players for a specified inning.
    
    .DESCRIPTION
    This PowerShell function takes a list of innings with assigned players and a list of available players,
    and it determines which players are available for a specified inning number ($Start). It excludes players who
    were on the bench in the previous inning or the current inning and players who have already been assigned
    to a position in the current inning. The result is a shuffled list of players available for the specified inning.
    
    .PARAMETER Innings
    An array of innings, each containing 'Player', 'Inning', 'Position', 'Jersey', 'PositionValue' and 'PositionNumber' properties.
    
    .PARAMETER TeamMembersList
    An array of players' names that are available for selection in the game.
    $teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")
    
    .PARAMETER Start
    An optional parameter (default value is 1) representing the inning number for which players' availability needs to be determined.
    
    .EXAMPLE
    $innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
    )
    Get-PlayerAvailableForInning -Innings $GameInnings -TeamMembersList $AvailablePlayers -Start 3
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("GameInnings")]
        [array]$Innings,

        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("AvailablePlayers")]
        [array]$TeamMembersList,

        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("CurrentInning")]
        [int]$Start = 1
    )

    $PlayersAvailableInning
    $IneligiblePlayer = @()
    foreach ($inning in $Innings) {
        if ($inning.Player -and $null -notcontains $inning.Player -and $inning.Player -ne '') {
            if ($inning.inning -in ($Start-1) -and $inning.Position -like "Bench*") {
            $IneligiblePlayer += $inning.Player
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] Ineligible player for bench - $($inning.Player) was on the bench the previous inning."
            }

            # The code checks whether a player was already assigned a position for the current inning ($inning.inning -eq $Start). 
            # If this condition is met and the player's name is not empty ($inning.Player), it means that the player has already been
            # assigned a position for the current inning.
            if ($inning.Player -and $inning.inning -eq $Start -and $IneligiblePlayer -notcontains $inning.Player) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] Ineligible player for bench - $($inning.Player) has already been assigned to position: $($inning.Position) for Inning: $($inning.Inning)"
                $IneligiblePlayer += $inning.Player
            }

            if ($inning.inning -in ($Start+1) -and $inning.Position -like "Bench*" -and $IneligiblePlayer -notcontains $inning.Player) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)]Ineligible player for bench - $($inning.Player) has been assigned to position: $($inning.Position) for Inning: $($inning.Inning)"
                $IneligiblePlayer += $inning.Player
            }
        }
    }

    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Ineligible PlayerPlayers for assigning to bench this inning $IneligiblePlayer"
    $PlayersAvailableInning = $TeamMembersList | Where-Object { $_ -notin $IneligiblePlayer }
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Players Available for assignment $PlayersAvailableInning"
    if ($PlayersAvailableInning) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] Shuffling available players."
        $PlayersAvailableInning = $PlayersAvailableInning | Get-Random -Count $PlayersAvailableInning.Count
    }
    $PlayersAvailableInning
}

function Get-PlayerDiscovery {
    <#
    .SYNOPSIS
    Compares two objects and returns the differences found in the second object.

    .DESCRIPTION
    This function compares two objects (ReferenceObject and DifferenceObject) and identifies the differences found in the DifferenceObject.
    It returns the properties from the DifferenceObject that are different from the corresponding properties in the ReferenceObject.

    .PARAMETER ReferenceObject
    The reference object against which the differences are compared.

    .PARAMETER DifferenceObject
    The object containing the differences that need to be identified.

    .EXAMPLE
    $referenceObject = @(
        "Catcher"
        "Center Field"
        "First Base"
    )
    $differenceObject = @(
        "Catcher"
        "Left Field"
        "Pitcher"
    )
    $differences = Get-PlayerDiscovery -ReferenceObject $referenceObject -DifferenceObject $differenceObject

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $ReferenceObject,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        $DifferenceObject
    )
    Process {
        $PositionDiscovery = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject | 
            Where-Object { $_.SideIndicator -eq '=>' } | Select-Object -ExpandProperty InputObject

        if (-not $PositionDiscovery) {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - PositionDiscovery does not exist - objects are the same"
            $PositionDiscovery = $DifferenceObject
        }

        $PositionDiscovery
    }
}

function Get-PlayerTotalPositionValue {
    <#
    .SYNOPSIS
    Calculates the total position value for each player in a baseball team.

    .DESCRIPTION
    This function calculates the total position value for each player in a baseball team based on the provided team members list and innings data.
    It sums up the position values for each player from the innings data and returns the total position value for each player.

    .PARAMETER TeamMembersList
    An array of team members representing players' names.

    .PARAMETER Innings
    An array containing player data for each inning, including the player name and position value.

    .EXAMPLE
    $teamMembersList = @("Player 1", "Player 2", "Player 3")
    $innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
    )
    $playerStats = Get-PlayerTotalPositionValue -TeamMembersList $teamMembersList -Innings $innings

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $TeamMembers,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        $Innings
    )
    $playersStats = foreach ($member in $TeamMembers) {
        $totalPositionValue = ($Innings | Where-Object { $_.Player -eq $member } | Measure-Object -Property PositionValue -Sum).Sum
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player: $member"
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Total Position Value: $totalPositionValue"
        [pscustomobject]@{
            Name = $member
            TotalPositionValue = $totalPositionValue
        }
    }
    $playersStats
}



function Get-PlayerPosition {
    <#
    .SYNOPSIS
    Retrieves the position of a player in a baseball team based on the provided player name and innings data.

    .DESCRIPTION
    This function retrieves the position of a player in a baseball team based on the provided player name and innings data.
    It filters the innings data to find the player's entry and returns the corresponding position.

    .PARAMETER Name
    The name of the player for whom the position needs to be retrieved.

    .PARAMETER Innings
    An array containing player data for each inning, including the player name and position.

    .EXAMPLE
    $inningsData = @(
        [PSCustomObject]@{ Player = "Player 1"; Position = "Pitcher" },
        [PSCustomObject]@{ Player = "Player 2"; Position = "Catcher" },
        [PSCustomObject]@{ Player = "Player 3"; Position = "Short Stop" }
    )
    $playerName = "Player 2"
    $playerPosition = Get-PlayerPosition -Name $playerName -Innings $inningsData
    # Output: Position of "Player 2" is "Catcher"

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $Name,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        $Innings
    )
    $result = $Innings | Where-Object { $_.Player -eq $Name }
    $result
}

function Get-BenchPlayerold {
    <#
    .SYNOPSIS
    Retrieves the count of bench appearances for each player in a baseball team.

    .DESCRIPTION
    This function calculates the count of bench appearances for each player in a baseball team based on the provided team members list and innings data.
    It counts the number of times each player appeared in the "Bench" position in the innings data and returns the count for each player.

    .PARAMETER TeamMembersList
    An array of team members representing players' names.

    .PARAMETER Innings
    An array containing player data for each inning, including the player name and position.

    .EXAMPLE
    $teamMembersList = @("Player 1", "Player 2", "Player 3")
    $innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
    )
    $benchPlayerStats = Get-BenchPlayer -TeamMembersList $teamMembersList -Innings $innings

    .NOTES
    Author: Your Name
    Date: Today's Date
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $TeamMembersList,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        $Innings
    )

    if (-not $TeamMembersList -or -not $Innings) {
        Write-Error "TeamMembersList or innings data cannot be empty."
        return
    }
    $Result = foreach ($member in $TeamMembersList) {
        $BenchCount = ($Innings | Where-Object { $_.Position -like "Bench*" -and $_.Player -eq $member }).Count
        [pscustomobject] @{
            Name = $member
            BenchCount = $BenchCount
        }
    }

    $Result
}
function Get-BenchPlayer {
    <#
    .SYNOPSIS
    Retrieves the count of bench appearances for each player in a baseball team.

    .DESCRIPTION
    This function calculates the count of bench appearances for each player in a baseball team based on the provided team members list and innings data.
    It counts the number of times each player appeared in the "Bench" position in the innings data and returns the count for each player.

    .PARAMETER TeamMembersList
    An array of team members representing players' names.

    .PARAMETER Innings
    An array containing player data for each inning, including the player name and position.

    .EXAMPLE
    $teamMembers = @("Player 1", "Player 2", "Player 3")
    $innings = @(
        [PSCustomObject]@{ Inning = 1; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
        [PSCustomObject]@{ Inning = 2; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
        [PSCustomObject]@{ Inning = 3; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
        [PSCustomObject]@{ Inning = 4; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
        [PSCustomObject]@{ Inning = 5; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
        [PSCustomObject]@{ Inning = 6; Player = "Player 1"; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
    )
    $benchPlayerStats = Get-BenchPlayer -TeamMembersList $teamMembersList -Innings $innings

    .NOTES
    Author: Your Name
    Date: Today's Date
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $TeamMembers,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $Innings
    )
    try {
        foreach ($member in $TeamMembers) {
            <#
            $PlayerBenchInning = $Innings | Where-Object { $_.Position -like "Bench*" -and $_.Player -eq $member }
            Write-Host "PlayerBenchInning Type: $($PlayerBenchInning.GetType())"
            
            $total = if ($PlayerBenchInning.Count -gt 0) {
                $PlayerBenchInning.Count
            } else {
                0
            }
            [pscustomobject] @{
                Name = $member
                BenchCount = $total
            }
            #>
            
            $PlayerBenchInning = @()
            $PlayerBenchInning = ($Innings | Where-Object { $_.Position -like "Bench*" -and $_.Player -eq $member }).Player
            $total = if ($PlayerBenchInning) {
                $PlayerBenchInning.Count
            } else {
                0
            }
            [pscustomobject] @{
                Name = $member
                BenchCount = $total
            }
            
        }
    } catch {
        Write-Error "An error occurred: $($error[0])"
    }
}

function Get-PitcherOfInning {
    <#
.SYNOPSIS
    Retrieves the pitcher for a specific inning from a collection of innings.

.DESCRIPTION
    The Get-PitcherOfInning function retrieves the pitcher for a specific inning from a collection of innings. 
    It takes a collection of innings as input and optionally allows specifying the inning number to search for a pitcher.
    If no pitcher is found for the specified inning, a warning will be displayed.

.PARAMETER Innings
    Specifies the collection of innings from which to retrieve the pitcher. This parameter is mandatory and accepts input from the pipeline.

.PARAMETER Inning
    Specifies the inning number for which the pitcher needs to be retrieved. This parameter is optional.
    If not specified, the function will default to searching for the pitcher in the first inning (Inning = 1).

.EXAMPLE
    $inningsData = @(
        [PSCustomObject]@{ Position = "Catcher"; Inning = 1 },
        [PSCustomObject]@{ Position = "Pitcher"; Inning = 1 },
        [PSCustomObject]@{ Position = "Outfielder"; Inning = 1 },
        [PSCustomObject]@{ Position = "Pitcher"; Inning = 2 },
        [PSCustomObject]@{ Position = "Shortstop"; Inning = 2 }
    )
    Get-PitcherOfInning -Innings $inningsData -Inning 2

    This example retrieves the pitcher for Inning 2 from the given collection of innings data.

.INPUTS
    System.Object

    Accepts a collection of innings as input from the pipeline.

.OUTPUTS
    System.Object

    Returns the pitcher object found in the specified inning from the input collection of innings.
    If no pitcher is found, the function returns $null.

.NOTES
    The Get-PitcherOfInning function is intended to work with collections of innings, where each inning is represented as a custom object.
    The custom object should have "Position" and "Inning" properties, among others.

    Each custom object representing an inning should have a "Position" property specifying the player's position in that inning (e.g., "Pitcher").
    Additionally, each custom object should have an "Inning" property specifying the inning number (e.g., 1, 2, 3, ...).

    If there are multiple pitchers in the collection for the specified inning, the function will return the first one found.

.LINK
    about_Functions
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $Innings,

        [Parameter(Position=1, Mandatory=$false)]
        #[ValidateScript({ $_ -gt 0 }, ErrorMessage = "Inning number must be greater than 0.")]
        $Inning = 1
    )

    $Pitcher = $Innings | Where-Object { $_.Position -eq "Pitcher" -and $_.Inning -eq $Inning }

    if (-not $Pitcher) {
        Write-Warning -Message "No pitcher found for inning $Inning."
    }

    $Pitcher
}


Function Get-PlayerPositionValueInInning {
    <#
    .SYNOPSIS
    Retrieves the position and position value of a player in a specific inning.

    .DESCRIPTION
    This function retrieves the position and position value of a player in a specific inning based on the provided player name, innings data, and inning number.
    It filters the innings data to find the player's entry in the specified inning and returns the corresponding position and position value.

    .PARAMETER Player
    The name of the player for whom the position and position value need to be retrieved.

    .PARAMETER Innings
    An array containing player data for each inning, including the player name, position, and position value.

    .PARAMETER Inning
    The inning number for which the player's position and position value need to be retrieved.

    .EXAMPLE
    $inningsData = @(
        [PSCustomObject]@{ Player = "Player 1"; Position = "Pitcher"; PositionValue = 1.7; Inning = 1 },
        [PSCustomObject]@{ Player = "Player 2"; Position = "Catcher"; PositionValue = 1.7; Inning = 1 },
        [PSCustomObject]@{ Player = "Player 3"; Position = "Short Stop"; PositionValue = 1.0; Inning = 2 }
    )
    $playerName = "Player 2"
    $targetInning = 1
    $playerPositionValue = Get-PlayerPositionValueInInning -Player $playerName -Innings $inningsData -Inning $targetInning
    # Output: Player 2 has position "Catcher" with a position value of 1.7 in inning 1.

    .NOTES
    Author: Your Name
    Date: Today's Date
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ParameterSetName='CmdletParamSet')]
        [Alias("PlayerName")]
        [string]$Player,

        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ParameterSetName='CmdletParamSet')]
        [Alias("GameInnings")]
        [array]$Innings,

        [Parameter(Mandatory=$true, Position=2, ValueFromPipeline=$true, ParameterSetName='CmdletParamSet')]
        [Alias("CurrentInning")]
        [int]$Inning
    )
    Begin
    {
        $TotalPositionValue = 0
        $Position = ""
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Inning $Inning --------"
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Looking up player: $player"
    }
    Process
    {
        $CurrentInning = $Innings | Where-Object {$_.inning -eq $Inning}
        Foreach ($pos in $CurrentInning) {
            If ($pos.player -eq $player){
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player Lookup Match $player"
                $TotalPositionValue += $pos.PositionValue
                $Position = $pos.position
            }
        }
    }
    End 
    {
        If (-not($position)) {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Position not yet defined $player"
        }
        [PSCustomObject]@{
            Name = $player
            TotalPositionValue = $TotalPositionValue
            Position = $Position  
        }
    }
}

function Get-NonPitchers {
    <#
    .SYNOPSIS
    Retrieves the non-pitchers from the given list of team members and pitchers.

    .DESCRIPTION
    This function takes an array of team members and an array of pitchers. It then compares the two arrays to find the non-pitchers, i.e., players who are not included in the list of pitchers.
    The function returns an array of non-pitchers.

    .PARAMETER TeamMembersList
    An array of team members' names.

    .PARAMETER Pitchers
    An array of objects representing pitchers, each containing a "Name" property.

    .EXAMPLE
    $teamMembers = @("Player 1", "Player 2", "Player 3", "Player 4")
    $pitchers = @(
        [pscustomobject]@{ Name = "Player 2" },
        [pscustomobject]@{ Name = "Player 4" }
    )

    $nonPitchers = Get-NonPitchers -TeamMembersList $teamMembers -Pitchers $pitchers
    # Output: "Player 1" and "Player 3"

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("TeamMembers")]
        [ValidateNotNullOrEmpty()]
        [array]$TeamMembersList,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object[]]$Pitchers
    )

    # Extract pitcher names from the objects
    $PitcherNames = $Pitchers | ForEach-Object { $_.Name }

    # Compare the two arrays to find the non-pitchers
    $NonPitchers = Compare-Object -ReferenceObject $TeamMembersList -DifferenceObject $PitcherNames -PassThru |
                   Where-Object { $_ -ne $null }

    # If no non-pitchers were found, issue a warning
    if (-not $NonPitchers) {
        Write-Warning "No non-pitchers found."
    }

    # Return the non-pitchers array
    $NonPitchers
}


function Get-PlayerAssignedPosition {
    <#
.SYNOPSIS
Get the assigned position for a player from a list of possible positions.

.DESCRIPTION
This PowerShell function takes a list of assigned positions for a player and a list of possible positions. 
It discovers the player's assigned position and outputs the position.

.PARAMETER AssignedPosition
An array of strings representing the assigned positions for the player.

.PARAMETER PositionList
An optional array of strings representing the list of possible positions. 
Defaults to a list of common baseball positions.

.PARAMETER PositionCategory
Specify the position category ('outfield' or 'infield'). Defaults to 'outfield'.

.EXAMPLE
# Get the assigned position for player 'John' from a list of possible positions
$AssignedPosition = @("Pitcher", "Catcher", "First Base")
Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionCategory "infield"
# Output: First Base

# Get the assigned position for player 'Alice' from a list of possible positions
$AssignedPosition = @("Right Field", "Left Field", "Center Field")
Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionCategory "outfield"
# Output: Right Field
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$false, ValueFromPipeline = $true, HelpMessage = "Specify the assigned position(s).")]
        [string[]]$AssignedPosition,

        [Parameter(Position=1, Mandatory=$false, ValueFromPipeline = $true, HelpMessage = "Specify the list of possible positions.")]
        [string[]]$PositionList = @("Catcher", "First Base", "Second Base", "Short Stop", "Third Base", "Left Field", "Right Field", "Center Field"),

        [Parameter(Position=2, Mandatory=$true, ValueFromPipeline = $true, HelpMessage = "Specify the position category ('outfield' or 'infield').")]
        [ValidateSet("outfield", "infield")]
        [string]$PositionCategory = "outfield"
    )

    Begin {
        $ValidPositions = if ($PositionCategory -eq "outfield") {
            @("Left Field", "Right Field", "Center Field")
        } else {
            @("Catcher", "First Base", "Second Base", "Short Stop", "Third Base")
        }
    }

    Process {
        $PositionDiscover = Compare-Object -ReferenceObject $AssignedPosition -DifferenceObject $PositionList | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -ExpandProperty InputObject

        $AssignedPosition = $AssignedPosition | Where-Object { $_ -in $ValidPositions }

        if ($PositionDiscover) {
            $position = $PositionDiscover | Select-Object -First 1
        } elseif ($AssignedPosition) {
            $position = $AssignedPosition | Select-Object -First 1
        } else {
            $position = $ValidPositions | Select-Object -First 1
        }
    }

    End {
        $position
    }
}

function Set-PlayerPositionOutfielder {
    <#
    .SYNOPSIS
    Assigns a player to an outfielder position in a baseball team.

    .DESCRIPTION
    This function assigns a player to an outfielder position in a baseball team based on the provided position, assigned outfielders hashtable, and player name.
    It checks if the provided position is available in the hashtable of assigned outfielders. If the position is available, it assigns the player to that position.
    If the position is already assigned, a warning message will be displayed.

    .PARAMETER Position
    The outfielder position to be assigned to the player.

    .PARAMETER AssignedOutfielders
    A hashtable containing the outfielder positions and their corresponding assigned players.

    .PARAMETER Player
    The name of the player to be assigned to the outfielder position.

    .EXAMPLE
    $assignedOutfielders = @{
        "Left Field" = "Player A"
        "Center Field" = "Player B"
    }
    $position = "Right Field"
    $playerName = "Player C"
    Set-PlayerPositionOutfielder -Position $position -AssignedOutfielders $assignedOutfielders -Player $playerName

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Position,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        [hashtable]$AssignedOutfielders,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Player
    )

    if ($AssignedOutfielders.ContainsKey($Position)) {
        Write-Warning "The position '$Position' is already assigned to $($AssignedOutfielders[$Position])."
    }
    else {
        $AssignedOutfielders[$Position] = $Player
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player '$Player' assigned to position '$Position'."
    }
}


function Set-PlayerPosition {
    <#
    .SYNOPSIS
    Assigns a player to a specified position in the infield.

    .DESCRIPTION
    This function allows you to assign a player to a specific position in the infield. It takes three parameters: Position, AssignedInfielders, and Player. The Position parameter specifies the infield position where the player will be assigned. The AssignedInfielders parameter is a hashtable that stores the assignments of infield positions to players. The Player parameter contains the name of the player to be assigned to the specified position.

    .PARAMETER Position
    The infield position to which the player will be assigned.

    .PARAMETER AssignedInfielders
    A hashtable that stores the current assignments of infield positions to players.

    .PARAMETER Player
    The name of the player to be assigned to the specified position.

    .EXAMPLE
    $assignedInfielders = @{}
    Set-PlayerPosition -Position "Shortstop" -AssignedInfielders $assignedInfielders -Player "John Doe"
    # Output: Player 'John Doe' assigned to position 'Shortstop'.

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Position,

        [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
        [hashtable]$AssignedInfielders,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Player
    )

    if ($AssignedInfielders.ContainsKey($Position)) {
        Write-Warning "The position '$Position' is already assigned to $($AssignedInfielders[$Position])."
    }
    else {
        $AssignedInfielders[$Position] = $Player
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player '$Player' assigned to position '$Position'."
    }
}


function Set-OutField {
    <#
    .SYNOPSIS
    Assigns players to outfield positions based on their usage in previous innings.

    .DESCRIPTION
    This function takes an array of innings and an array of players' outfield usage as input. It assigns players to outfield positions (Left Field, Center Field, Right Field) based on their usage in previous innings.

    .PARAMETER Innings
    An array of innings, each containing a 'Player', 'Inning', 'Position', and 'PositionValue' property.

    .PARAMETER OutfielderUsage
    An array of players' outfield usage. Each element should have 'Name', 'EligiblePositions', and 'PositionCount' properties.

    .EXAMPLE
    $innings = @(
        [PSCustomObject]@{ Inning = 1; Player = "Player1"; Position = "Catcher"; PositionValue = 1 },
        [PSCustomObject]@{ Inning = 1; Player = "Player2"; Position = "Pitcher"; PositionValue = 1 },
        [PSCustomObject]@{ Inning = 1; Player = "Player3"; Position = "First Base"; PositionValue = 2 },
        [PSCustomObject]@{ Inning = 2; Player = "Player1"; Position = "Left Field"; PositionValue = 3 },
        [PSCustomObject]@{ Inning = 2; Player = "Player4"; Position = "Center Field"; PositionValue = 3 },
        [PSCustomObject]@{ Inning = 2; Player = "Player5"; Position = "Right Field"; PositionValue = 3 }
    )
    $outfielderUsage = @(
        [PSCustomObject]@{ Name = "Player1"; EligiblePositions = @("Center Field"); PositionCount = 1 },
        [PSCustomObject]@{ Name = "Player2"; EligiblePositions = @("Center Field"); PositionCount = 1 },
        [PSCustomObject]@{ Name = "Player3"; EligiblePositions = @("Left Field", "Center Field"); PositionCount = 2 },
        [PSCustomObject]@{ Name = "Player4"; EligiblePositions = @("Center Field", "Right Field"); PositionCount = 2 },
        [PSCustomObject]@{ Name = "Player5"; EligiblePositions = @("Center Field", "Right Field"); PositionCount = 2 }
    )
    $result = Set-OutField -Innings $innings -OutfielderUsage $outfielderUsage
    $result

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $OutfielderUsage
    )
    Begin
    {
        $Outfield = @("Left Field","Right Field","Center Field")
        $Assigned = $false
        $LeftFieldList = @()
        $RightFieldList = @()
        $CenterFieldList = @()
        [System.Collections.ArrayList]$AssignedList = @()
        $AssignedOutfielders = @{}
        $PlayerEligiblePositions = @()
        $AssignedPosition = @()
        $AssignedPlayerList = @()
    }
    Process 
    {
        Foreach ($player in $OutfielderUsage) {
            $Name = $player.name
            $EligiblePositions = @()
                If (Test-PlayedPosition -Name $Name -Innings $Innings -Position "Left Field"){
                } else {
                    # The Player has not played Left Field yet this game
                    $LeftFieldList += $Name
                    $EligiblePositions += "Left Field"
                }
                If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Right Field")){
                    # The Player has not played Right Field yet this game
                    $RightFieldList += $Name
                    $EligiblePositions += "Right Field"
                }
                If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Center Field")){
                    # The Player has not played Center Field yet this game
                    $CenterFieldList += $Name
                    $EligiblePositions += "Center Field"
                }
                $PlayerEligiblePositions += [pscustomobject]@{
                    PlayerName = $Name
                    EligiblePositions = $EligiblePositions
                    PositionCount = $EligiblePositions.Count
                }
        }

        # Define Player Objects
        $FilteredPlayers = $PlayerEligiblePositions | Sort-Object -Property PositionCount | Select-Object -last 3
        $PlayerOnePositions = $FilteredPlayers[0].EligiblePositions
        $PlayerOne = $FilteredPlayers[0].PlayerName
        $PlayerTwoPositions = $FilteredPlayers[1].EligiblePositions
        $PlayerTwo = $FilteredPlayers[1].PlayerName
        $PlayerThreePositions = $FilteredPlayers[2].EligiblePositions
        $PlayerThree = $FilteredPlayers[2].PlayerName

        If ($PlayerOnePositions.length -eq 1) {
           $PlayerThreePositions = $PlayerThreePositions | Where-object {$_ -ne $PlayerOnePositions[0]}
        }
        If ( $FilteredPlayers.PlayerName.count -gt 1) {
            # Discovery 
            # Discover Player Two optimal position
            If ($PlayerOnePositions -and $PlayerTwoPositions){
                $PositionDiscoverTwo = Get-PlayerDiscovery -ReferenceObject $PlayerOnePositions -DifferenceObject $PlayerTwoPositions
            }
            # Discover Player Three position 
            If ($PlayerTwoPositions -and $PlayerThreePositions){
                $PositionDiscoverThree = Get-PlayerDiscovery -ReferenceObject $PositionDiscoverTwo -DifferenceObject $PlayerThreePositions
            }
            # Assignment
            # Assigning Player Three to a position 
            If ($PlayerThree){
                $position = Get-PlayerAssignedPosition -AssignedPosition $PlayerThreePositions -PositionList $PositionDiscoverThree -PositionCategory "outfield"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player $PlayerThree
            } else { 
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No Player Three"
                $position = "Center Field"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            }
        
            # Assigning Player Two to a position 
            If($PlayerTwo){                
                $position = Get-PlayerAssignedPosition -AssignedPosition $PlayerThreePositions -PositionList $PositionDiscoverTwo -PositionCategory "outfield"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player $PlayerTwo
            } else { 
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No Player Two"
                $position = "Right Field"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            }
                
            # Assigning Player One to a position
            If($PlayerOne){
                $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $Outfield -PositionCategory "outfield"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player $PlayerOne
            } else { 
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No Player One"
                $position = "Left Field"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            }
        } else {
            Set-PlayerPositionOutfielder -position "Right Field" -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            Set-PlayerPositionOutfielder -position "Left Field" -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            $AssignedPosition += "Right Field"
            $AssignedPosition += "Left Field"
            If($PlayerOne){
                $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $Outfield -PositionCategory "outfield"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player $PlayerOne
            } else { 
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No Player One"
                $position = "Left Field"
                $AssignedPosition += $position
                Set-PlayerPositionOutfielder -position $position -AssignedOutfielders $AssignedOutfielders -player "UnAssigned"
            }
        }
    }
    End
    {
        $AssignedOutfielders
    }
}


function Set-InfieldFieldPositions {
    <#
.SYNOPSIS
Assigns players to infield positions based on their usage in previous innings.

.DESCRIPTION
This function takes an array of innings and an array of players' infield usage as input. It assigns players to infield positions (Catcher, First Base, Second Base, Short Stop, Third Base) based on their usage in previous innings.

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', and 'PositionValue' properties.

.PARAMETER PlayerUsage
An array of players' infield usage. Each element should have 'Name', 'EligiblePositions', and 'PositionCount' properties.

.EXAMPLE
$innings = @(
    [PSCustomObject]@{ Inning = 1; Player = "Player1"; Position = "Catcher"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player2"; Position = "First Base"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player3"; Position = "Second Base"; PositionValue = 2 },
    [PSCustomObject]@{ Inning = 2; Player = "Player1"; Position = "Catcher"; PositionValue = 3 },
    [PSCustomObject]@{ Inning = 2; Player = "Player4"; Position = "Third Base"; PositionValue = 3 },
    [PSCustomObject]@{ Inning = 2; Player = "Player5"; Position = "First Base"; PositionValue = 3 }
)
$playerUsage = @(
    [PSCustomObject]@{ Name = "Player1"; EligiblePositions = @("First Base", "Third Base"); PositionCount = 2 },
    [PSCustomObject]@{ Name = "Player2"; EligiblePositions = @("First Base", "Second Base", "Third Base"); PositionCount = 3 },
    [PSCustomObject]@{ Name = "Player3"; EligiblePositions = @("Second Base", "Third Base"); PositionCount = 2 },
    [PSCustomObject]@{ Name = "Player4"; EligiblePositions = @("Third Base"); PositionCount = 1 },
    [PSCustomObject]@{ Name = "Player5"; EligiblePositions = @("First Base"); PositionCount = 1 }
)
$result = Set-InfieldFieldPositions -Innings $innings -PlayerUsage $playerUsage
$result

.NOTES
Author: Jason Gebhart
Date: 8/3/2023
#>
    [Cmdletbinding()]
    param (
      [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
      $Innings,
      [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
      $PlayerUsage
    )
    Begin
    {
      $Infield = @("Catcher","First Base","Second Base","Short Stop","Third Base")
      $CatcherList = @()
      $FirstBaseList = @()
      $SecondBaseList = @()
      $ShortStopList = @()
      $ThirdBaseList = @()
      $InfieldPositions = @()
      $AssignedInfielders = @{}
      $AssignedPlayerList = @()
      $EligiblePosiitons = @()
      $PlayerEligiblePositions = @()
      $AssignedPosition = @()
      $AvailablePositionsList = @()
      $PlayerOneAssigned = $false
    }
    Process
    {
      $FilteredInfielders = $PlayerUsage | Sort-object -Property TotalPositionValue |
        Select-Object -first 5
  
      Foreach ($player in $FilteredInfielders) {
        $EligiblePositions = @()
        $Name = $player.name
        If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Catcher")){
            $catcherList += $Name
            $EligiblePositions += "Catcher"
        }
        If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "First Base")){
            $FirstBaseList += $Name
            $EligiblePositions += "First Base"
        }
        If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Second Base")){
            $SecondBaseList += $Name
            $EligiblePositions += "Second Base"
        }
        If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Short Stop")){
            $ShortStopList += $Name
            $EligiblePositions += "Short Stop"
        }
        If (-not(Test-PlayedPosition -Name $Name -Innings $Innings -Position "Third Base")){
            $ThirdBaseList += $Name
            $EligiblePositions += "Third Base"
        }
        $PlayerEligiblePositions += [pscustomobject]@{
          PlayerName = $Name
          EligiblePositions = $EligiblePositions
          PositionCount = $EligiblePositions.Count
        }
      }
          
      $FilteredPlayers = $PlayerEligiblePositions | Sort-Object -Property PositionCount | Select -first 5
      $PlayerOnePositions = $FilteredPlayers[0].EligiblePositions
      $PlayerOne = $FilteredPlayers[0].PlayerName
      $PlayerTwoPositions = $FilteredPlayers[1].EligiblePositions
      $PlayerTwo = $FilteredPlayers[1].PlayerName
      $PlayerThreePositions = $FilteredPlayers[2].EligiblePositions
      $PlayerThree = $FilteredPlayers[2].PlayerName
      $PlayerFourPositions = $FilteredPlayers[3].EligiblePositions
      $PlayerFour = $FilteredPlayers[3].PlayerName
      $PlayerFivePositions = $FilteredPlayers[4].EligiblePositions
      $PlayerFive = $FilteredPlayers[4].PlayerName
  <#
         If ($PlayerOnePositions.length -eq 1) {
              $position = $PlayerOnePositions
              $AssignedPosition += $position
              Write-Warning -Message "[$($MyInvocation.MyCommand)] - Assigning Player $name to Position $position"
              Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerOne
              $PlayerOneAssigned = $true
         }
  #>
  
      # Discovery 
      # Discover Player Two optimal position
      If ($PlayerOnePositions -and $PlayerTwoPositions){
        $PositionDiscoverTwo = Get-PlayerDiscovery -ReferenceObject $PlayerOnePositions -DifferenceObject $PlayerTwoPositions
      }
      # Discover Player Three position 
      If ($PositionDiscoverTwo -and $PlayerThreePositions){
        $PositionDiscoverThree = Get-PlayerDiscovery -ReferenceObject $PositionDiscoverTwo -DifferenceObject $PlayerThreePositions
      }
      # Discover Player Four optimal position
      If ($PositionDiscoverThree -and $PlayerFourPositions){
        $PositionDiscoverFour = Get-PlayerDiscovery -ReferenceObject $PositionDiscoverThree -DifferenceObject $PlayerFourPositions
      }
      # Discover Player Five position 
      If ($PositionDiscoverFour -and $PlayerFivePositions){
        $PositionDiscoverFive = Get-PlayerDiscovery -ReferenceObject $PositionDiscoverFour -DifferenceObject $PlayerFivePositions
      }
  
      # Assignment
  
      # Assigning Player One to a position
      If($PlayerOneAssigned){
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $PlayerOne already assigned $position"
      } else {
        $position = Get-PlayerAssignedPosition -AssignedPosition $PlayerOnePositions -PositionList $PlayerOnePositions -PositionCategory "infield"
        $AssignedPosition += $position
        Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerOne
      }
  
      # Assigning Player Two to a position                 
      If ($PlayerTwo){
        $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $PositionDiscoverTwo -PositionCategory "infield"
        $AssignedPosition += $position
        Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerTwo
      }
      # Assigning Player Five to a position
      If ($PlayerFive){
        $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $PositionDiscoverFive -PositionCategory "infield"
        $AssignedPosition += $position
        Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerFive
      }
      # Assigning Player Four to a position
      If ($PlayerFour){
        $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $PositionDiscoverFour -PositionCategory "infield"
        $AssignedPosition += $position
        Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerFour
      }
      # Assigning Player Three to a position 
      If ($PlayerThree){
        $position = Get-PlayerAssignedPosition -AssignedPosition $AssignedPosition -PositionList $Infield -PositionCategory "infield"
        $AssignedPosition += $position
        Set-PlayerPosition -position $position -AssignedInfielders $AssignedInfielders -player $PlayerThree
      }
  
    }
    End
    {
      $AssignedInfielders
    }
  }
  


function Set-CustomPosition {
    <#
.SYNOPSIS
Sets custom positions for players in specific innings.

.DESCRIPTION
This function takes an array of innings, an array of custom positions, and the target inning as input. It assigns custom positions to players for the specified inning.

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', and 'PositionValue' properties.

.PARAMETER CustomPositions
An array of custom positions to be assigned in specific innings. Each element should have 'Name', 'Inning', and 'Position' properties.

.PARAMETER TargetInning
The inning for which custom positions need to be set.

.EXAMPLE
$innings = @(
    [PSCustomObject]@{ Inning = 1; Player = "Player1"; Position = "Catcher"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player2"; Position = "First Base"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player3"; Position = "Second Base"; PositionValue = 2 },
    [PSCustomObject]@{ Inning = 2; Player = "Player1"; Position = "Catcher"; PositionValue = 3 },
    [PSCustomObject]@{ Inning = 2; Player = "Player4"; Position = "Third Base"; PositionValue = 3 },
    [PSCustomObject]@{ Inning = 2; Player = "Player5"; Position = "First Base"; PositionValue = 3 }
)
$customPositions = @(
    [PSCustomObject]@{ Name = "CustomPlayer1"; Inning = 1; Position = "Short Stop" },
    [PSCustomObject]@{ Name = "CustomPlayer2"; Inning = 2; Position = "Third Base" }
)
$targetInning = 1
$result = Set-CustomPosition -Innings $innings -CustomPositions $customPositions -TargetInning $targetInning
$result

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $CustomPositions,
        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
        $TargetInning
    )

    Begin {
        $CustomPositions = $CustomPositions | Where-Object { $_.Inning -eq $TargetInning }
    }

    Process {
        # Assign Custom Positions
        # Loop Through CustomPositions Object
        Foreach ($custom in $CustomPositions) {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Evaluating Custom Position $($custom.Position) for inning $($custom.Inning) to be assigned to $($custom.Name)" 
            $currentPlayer = $null

            Foreach ($item in $Innings) {
                if ($item.Position -eq $custom.Position -and $item.Inning -eq $custom.Inning) {
                    $currentPlayer = $item.Player
                    $item.Player = $custom.Name
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assigning Position: $($custom.Position) to $($custom.Name) for inning $($item.Inning)" 
                }

                if ($item.Player -eq $custom.Name -and $item.Position -ne $custom.Position -and $item.Inning -eq $custom.Inning) {
                    $item.Player = $currentPlayer
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assigning $($item.Position) for inning $($item.Inning) back to $currentPlayer" 
                }
            }
        }
    }

    End {
        $Innings
    }
}


function Set-Jersey {
    <#
.SYNOPSIS
Sets jersey numbers for players in the innings based on the provided team members.

.DESCRIPTION
This function takes an array of innings and an array of team members as input. It assigns jersey numbers to players in the innings based on the jersey numbers specified for each team member.

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', and 'PositionValue' properties.

.PARAMETER TeamMembers
An array of team members, each containing 'Name' and 'Jersey' properties.

.EXAMPLE
$innings = @(
    [PSCustomObject]@{ Inning = 1; Player = "Player1"; Position = "Catcher"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player2"; Position = "First Base"; PositionValue = 1 },
    [PSCustomObject]@{ Inning = 1; Player = "Player3"; Position = "Second Base"; PositionValue = 2 }
)
$teamMembers = @(
    [PSCustomObject]@{ Name = "Player1"; Jersey = 10 },
    [PSCustomObject]@{ Name = "Player2"; Jersey = 25 },
    [PSCustomObject]@{ Name = "Player3"; Jersey = 7 }
)
$result = Set-Jersey -Innings $innings -TeamMembers $teamMembers
$result

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$Innings,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$TeamMembers
    )

    # Create a hashtable to store team members and their jersey numbers
    $TeamMembersHash = @{}
    foreach ($member in $TeamMembers) {
        $TeamMembersHash[$member.Name] = $member.Jersey
    }

    # Assign jersey numbers to players in innings
    foreach ($item in $Innings) {
        if ($TeamMembersHash.ContainsKey($item.Player)) {
            $item.Jersey = $TeamMembersHash[$item.Player]
        }
        else {
            $item.Jersey = $null
        }
    }

    # Output the updated innings
    $Innings
}


function Set-BenchOne {
<#
.SYNOPSIS
Sets the Bench One player for each inning based on the provided pitchers and non-pitchers.

.DESCRIPTION
This function takes an array of innings, an array of pitchers, an array of non-pitchers, and an optional parameter to specify the total number of active players. It assigns the Bench One player for each inning based on the provided criteria.

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', 'Jersey', 'PositionValue' and 'PositionNumber' properties.

.PARAMETER Pitchers
An array of pitchers, each containing 'Name', 'Position' and 'Inning' properties.

.PARAMETER NonPitchers
An array of non-pitchers, each containing 'Name' property.

.PARAMETER TotalActivePlayers (Optional)
The total number of active players. Default value is 11.

.EXAMPLE
$innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
)
$pitchers = @(
    [PSCustomObject]@{ Name = "Player1"; Inning = 1; Position = "Pitcher"},
    [PSCustomObject]@{ Name = "Player2"; Inning = 2; Position = "Pitcher"},
    [PSCustomObject]@{ Name = "Player3"; Inning = 3; Position = "Pitcher"},
    [PSCustomObject]@{ Name = "Player4"; Inning = 4; Position = "Pitcher"},
    [PSCustomObject]@{ Name = "Player5"; Inning = 5; Position = "Pitcher"},
    [PSCustomObject]@{ Name = "Player6"; Inning = 6; Position = "Pitcher"}
)

$nonPitchers = @("Player7", "Player8", "Player9", "Player10", "Player11")
$result = Set-BenchOne -Innings $innings -Pitchers $pitchers -NonPitchers $nonPitchers -TotalActivePlayers 11
$result

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $Pitchers,
        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
        $NonPitchers,
        [Parameter(Position=3,Mandatory=$false,ValueFromPipeline = $true)]
        $TotalActivePlayers=11
    )

    Begin
    {
    }
    Process
    {
        # Set Bench Players
        Foreach ($Inning in $Innings | Where-Object {$_.Position -eq "Bench One"}) {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assign Bench One to the Pitcher who pitches after this inning."
            # Exclude inning 6
            If (-not($inning.Player)) {
                switch ($Inning.Inning) {
                    "6"
                     {
                        # Inning Six. Check Total Number of players. If equal to 10 then assign the first pitcher to the last Bench spot
                        If ($TotalActivePlayers -eq 10) {
                            $Inning.Player = $pitchers | Where-Object {$_.inning -eq 1} |
                                Select-Object -ExpandProperty Name
                            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench One - Inning $($Inning.Inning): $($Inning.player)"
                        }   
                     }
                     "x4"
                     {
                     Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench One Not Set - Inning $($Inning.Inning)"
                     }
                    "x" 
                     {
                        $CurrentBenchPlayers = $null
                        #$Bench = $Innings | Where-Object {$_.Position -match "Bench*" -and $_.inning -eq $Inning}
                        $NotOnBench = @()
                        $PlayerUsage = @()
                        $CurrentBenchPlayers = Get-BenchPlayer -TeamMembers $TeamMembersList -Innings $Innings
                        Foreach ($player in $CurrentBenchPlayers) {
                            If ($player.Benchcount -eq 0 -and $pitchers.name -notcontains $player.name){
                                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Not on Bench - $($Player.Name)"
                                $NotOnBench += $player.Name
                            }
                        }
                        $CumalativePlayValue = Get-PlayerTotalPositionValue -TeamMembers $NotOnBench -Innings $Innings 
                        $TotalPlayerUsage = $CumalativePlayValue | Sort-object -Property TotalPositionValue -Descending 
                        Foreach ($i in $TotalPlayerUsage) {
                                 $PlayerUsage += [pscustomobject]@{
                                    Name = $i.name
                                    TotalPositionValue = $TotalPositionValue
                                }
                        }
                        $Inning.Player = $PlayerUsage | Select-Object -property Name,TotalPositionValue -First 1 |
                            Select-Object -ExpandProperty Name
                        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench One - Inning $($Inning.Inning): $($Inning.player)"
                     }
                    default
                     {
                        $Inning.Player = $pitchers | Where-Object {$_.inning -eq ($Inning.Inning + 1)} |
                            Select-Object -ExpandProperty Name
                        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench One - Inning $($Inning.Inning): $($Inning.player)"
                     }
                }                  
            }
        }
    }
    End
    {
    $Innings
    }
}


function Set-BenchByTotalValue {
    <#
.SYNOPSIS
Sets the Bench Three player for each inning based on the provided criteria.

.DESCRIPTION
This function takes a name for the Bench Three position, an array of innings, an array of team members, and optional start and end parameters. It assigns the Bench Three player for each inning based on the provided criteria such as total position value and bench count.

.PARAMETER Name
The name of the Bench Three position. Default value is "Bench Three".

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', and 'PositionValue' properties.

.PARAMETER TeamMembersList
An array of team members' names.
$teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")

.PARAMETER start (Optional)
The start inning for assigning the Bench Three player. Default value is 1.

.PARAMETER end (Optional)
The end inning for assigning the Bench Three player. Default value is 5.

.EXAMPLE
$Innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench One"; PositionValue = 0; PositionNumber = 10 }
)
$teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")
$Innings = Set-BenchByTotalValue -Name "Bench Three" -Innings $innings -TeamMembersList $teamMembersList -start 1 -end 5
$Innings

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Name,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
        $TeamMembersList,
        [Parameter(Position=3,Mandatory=$false,ValueFromPipeline = $true)]
        $start=1,
        [Parameter(Position=4,Mandatory=$false,ValueFromPipeline = $true)]
        $end=5
    )

    Begin
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Begin Inning $start"
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set-Bench Begin - $Name"
    }
    Process
    {
        # Set Bench Players
        Do 
        {
            If (($end - $start) -gt 1) {
                 Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Begin Inning $start"
            }
            $AllPlayersBenchFrequency = $null
            $PlayersAvailableInning = @()
            $BenchOptions = @()
            # Build list of players that were on the bench last inning or current inning
            # Mark Players already assigned to a position this inning ineligible
            $PlayersAvailableInning = Get-PlayerAvailableForInning -Innings $Innings -TeamMembersList $TeamMembersList -start $start
            # Count the number of times a player has been on the bench
            $AllPlayersBenchFrequency = Get-BenchPlayer -TeamMembers $PlayersAvailableInning -Innings $Innings

            Foreach ($player in $PlayersAvailableInning) {
                $BenchOptions += [pscustomobject]@{
                    Name = $player
                    BenchCount = ($AllPlayersBenchFrequency | Where-Object {$_.Name -eq $player} | Select-Object -Property BenchCount).BenchCount
                }
            }

            $PlayerUsage = @()
            $CumalativePlayValue = Get-PlayerTotalPositionValue -TeamMembers $PlayersAvailableInning -Innings $Innings -Verbose:$false
            $TotalPlayerUsage = $CumalativePlayValue | Sort-object -Property TotalPositionValue -Descending 
            Foreach ($i in $TotalPlayerUsage) {
                        $PlayerUsage += [pscustomobject]@{
                        Name = $i.name
                        TotalPositionValue = $i.TotalPositionValue
                    }
            }
            Foreach ($x in $PlayerUsage) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player: $($x.Name) TotalPositionValue: $($x.TotalPositionValue)"
            }
            # Check for all Named position entries (bench x) for this inning
            Foreach ($item in $Innings | Where-Object {$_.inning -eq $start -and $_.Position -eq $Name}) {
            
                $BenchPlayer = $PlayerUsage | Select-Object -property Name,TotalPositionValue -First 1 
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench Player: $($BenchPlayer.Name) Total Position: $($BenchPlayer.TotalPositionValue)"
                $item.Player = $BenchPlayer.Name
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $Name : $($item.player)"
            }
            ++$start
        }
        Until ($start -eq ($end+1))
    }
    End
    {
        $Innings
    }
}

function Set-Bench {
    <#
.SYNOPSIS
Sets bench players for multiple innings based on player availability and bench counts.

.DESCRIPTION
This function sets bench players for multiple innings. It takes an array of innings, an array of team members, and the optional parameters 'start' and 'end' to specify the range of innings. The function assigns players to the specified bench position based on their availability and the number of times they have been on the bench.

.PARAMETER Name
The name of the bench position to be filled. The default value is "Bench Three".

.PARAMETER Innings
An array of innings, each containing 'Inning', 'Player', and 'Position' properties.

.PARAMETER TeamMembersList
An array of team members' names.

.PARAMETER start
The starting inning number. The default value is 1.

.PARAMETER end
The ending inning number. The default value is 5.

.EXAMPLE
$Innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 }
)
$teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5")
$Innings = Set-Bench -Name "Bench Three" -Innings $innings -TeamMembersList $teamMembersList -start 1 -end 3
$Innings

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Name,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
        $TeamMembersList,
        [Parameter(Position=3,Mandatory=$false,ValueFromPipeline = $true)]
        $start=1,
        [Parameter(Position=4,Mandatory=$false,ValueFromPipeline = $true)]
        $end=5
    )

    Begin
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Set-Bench Begin - $Name"
    }

    Process
    {
        # Set Bench Players
        Do 
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Begin Inning $start"
            $AllPlayersBenchFrequency = $null
            $PlayersAvailableInning = @()
            # Build list of players that were on the bench last inning or current inning
            # Mark Players already assigned to a position this inning ineligible
            $PlayersAvailableInning = Get-PlayerAvailableForInning -Innings $Innings -TeamMembersList $TeamMembersList -start $start
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Players Available: $($PlayersAvailableInning.count)"
            # Count the number of times a player has been on the bench
            $AllPlayersBenchFrequency = Get-BenchPlayer -TeamMembers $TeamMembersList -Innings $Innings
            $BenchCountValue = ($AllPlayersBenchFrequency | Sort-Object -Property BenchCount | Select-Object -Property BenchCount -First 1).BenchCount
            $BenchPlayers = ($AllPlayersBenchFrequency | Where-Object {$_.BenchCount -eq $BenchCountValue}).Name

            #$$BenchPlayerList = ($AllPlayersBenchFrequency | Sort-Object -Property BenchCount -Descending | Select-Object -Last 2).Name
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - BenchCountValue: $BenchCountValue"
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - BenchPlayerList $BenchPlayers"
            $CumalativePlayValue = Get-PlayerTotalPositionValue -TeamMembers $BenchPlayers -Innings $Innings -Verbose:$false
            $TotalPlayerUsage = $CumalativePlayValue | Sort-object -Property TotalPositionValue -Descending 
            $PlayerUsage = $TotalPlayerUsage | ForEach-Object {
                [pscustomobject]@{
                    Name = $_.Name
                    TotalPositionValue = $_.TotalPositionValue
                }
            }

            $PlayerUsage = $PlayerUsage | Where-Object { $PlayersAvailableInning -contains $_.Name }
            $BenchPlayer = $PlayerUsage | Sort-Object -Property TotalPositionValue -Descending | Select-Object -property Name -First 1 

            # Check for all Named position entries (bench x) for this inning
            Foreach ($item in $Innings | Where-Object {$_.inning -eq $start -and $_.Position -eq $Name}) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench Player $($BenchPlayer.Name)"
                $item.Player = $BenchPlayer.Name
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $Name : $($item.player)"
            }
            ++$start
        }
        Until ($start -eq ($end+1))
    }

    End
    {
        $Innings
    }
}

function Set-BenchTwoInningTwo {
    <#
.SYNOPSIS
Assigns a player from the first inning's pitchers to the second inning's Bench Two position.

.DESCRIPTION
This function assigns a player from the first inning's pitchers to the Bench Two position in the second inning. It takes an array of innings, an array of first-inning pitchers, and an array of non-pitchers as input parameters. The function then assigns the appropriate player to the Bench Two position based on the specified conditions.

.PARAMETER Innings
An array of innings, each containing 'Inning', 'Player', and 'Position' properties.

.PARAMETER Pitchers
An array of first-inning pitchers, each containing 'inning' and 'Name' properties.

.PARAMETER NonPitchers
An array of non-pitchers' names.

.EXAMPLE
$Innings = @(
    [PSCustomObject]@{ Inning = 1; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 2; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 3; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 4; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 5; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 },
    [PSCustomObject]@{ Inning = 6; Player = $null; Position = "Bench Two"; PositionValue = 0; PositionNumber = 10 }
)
$pitchers = @(
    [PSCustomObject]@{ Inning = 1; Name = "Pitcher1" },
    [PSCustomObject]@{ Inning = 1; Name = "Pitcher2" }
)
$nonPitchers = @("Player1", "Player2", "Player3")
$Innings = Set-BenchTwoInningTwo -Innings $innings -Pitchers $pitchers -NonPitchers $nonPitchers
$Innings

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $Pitchers,
        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
        $NonPitchers
    )

    Begin
    {
        $TargetInning = 2
    }

    Process
    {
        # Set Bench Players
        Foreach ($Inning in $Innings | Where-Object {$_.Inning -eq $TargetInning}) {
            # Assign First inning pitcher to second inning Bench Two
            If (-not($Inning.Player)) {
                If ($Inning.Position -eq "Bench Two") {
                    $Inning.Player = $pitchers | Where-Object {$_.inning -eq 1} | 
                        Select-Object -ExpandProperty Name
                   Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench Two - Inning $($Inning.Inning): $($Inning.player)"
                }
            }
        }
    }

    End
    {
        $Innings
    }
}

function Set-CoreLateInnings {
    <#
    .SYNOPSIS
    Assigns players to the fielding positions in the core late innings.

    .DESCRIPTION
    This function assigns players to the fielding positions in the core late innings based on their performance and positions. It takes an array of innings, an array of team members, and an optional inning parameter (default value is 6). It then identifies the best-suited players for the infield and outfield positions and assigns them accordingly.

    .PARAMETER Innings
    $Innings = [System.Collections.ArrayList]@()
    An array of innings, each containing 'Player', 'Inning', 'Position', 'Jersey', 'PositionValue' and 'PositionNumber' properties.
    [PSCustomObject]@{ Player = 'Player 1'; Position = "Catcher"; Inning = 1; PositionValue = 1.7; PositionNumber = 2 },

    .PARAMETER TeamMembersList
    An array of team members' names.
    $teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")

    .PARAMETER Inning (Optional)
    The specific inning to set the core late innings positions. Default value is 6.

    .EXAMPLE
    $Innings = @(
        [PSCustomObject]@{ Player = 'Player1'; Position = "Pitcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 1 },
        [PSCustomObject]@{ Player = 'Player2'; Position = "Catcher"; Inning = $_; PositionValue = 1.7; PositionNumber = 2 },
        [PSCustomObject]@{ Player = 'Player3'; Position = "First Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 3 },
        [PSCustomObject]@{ Player = 'Player4'; Position = "Second Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 4 },
        [PSCustomObject]@{ Player = 'Player5'; Position = "Third Base"; Inning = $_; PositionValue = 1.7; PositionNumber = 5 },
    )
    $teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")
    $Innings = Set-CoreLateInnings -Innings $innings -TeamMembersList $teamMembersList -Inning 6
    $Innings

    .NOTES
    Author: Jason Gebhart
    Date: August 2, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        $TeamMembersList,
        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateRange(1, 9)]
        $Inning = 6
    )
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Beginning Inning - $Inning ***************************"
    $Pitcher = Get-PitcherofInning -Innings $Innings -Inning $Inning
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assigned Pitcher - $($Pitcher.Player)"
    $Bench = $Innings | Where-Object {$_.Position -match "Bench*" -and $_.inning -eq $Inning}
    Foreach ($player in $Bench) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Previously Assigned Bench Players - $($player.Player)"
    }

    $AssignedPosition = @()
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Duplicate TeamMemberList to TempTeamMembers"
    [System.Collections.ArrayList]$TempTeamMembers = $TeamMembersList
    # Remove a player from list if already assigned to a position for 
    # that inning
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - There are $($TempTeamMembers.Count) TempTeamMembers"
    Foreach ($item in $Innings | Where-Object {$_.inning -eq $Inning}) {
        If ($item.player) {
            $TempTeamMembers.Remove($item.player)
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Removing Previously assigned Player from TempTeamMembers $($item.player)"
            # Build Array with previous assigned positions 
            $AssignedPosition += $item.Position
        }
    } 
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - There are $($TempTeamMembers.Count) TempTeamMembers"
 
    $InfieldPositions = @("Catcher", "First Base", "Second Base", "Short Stop", "Third Base")
    $OutfieldPositions = @("Left Field", "Right Field", "Center Field")

    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Remove previously assigned players from the available players list"
    $AvailablePlayers = [System.Collections.ArrayList]@()

    <#
   foreach ($teamMember in $TempTeamMembers) {
        $playerInfo = [PSCustomObject]@{
            Name = $teamMember
            TotalPositionValue = ($Innings | Where-Object { $_.Player -eq $teamMember }).PositionValue | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        }
        $null = $AvailablePlayers.Add($playerInfo)  # Add each playerInfo object to the list
    }
    #>

  foreach ($teamMember in $TempTeamMembers) {
        $totalPositionValue = ($Innings | Where-Object { 
            $_.Player -eq $teamMember -and $_.Inning -le ($Inning + 2)
        }).PositionValue | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        
        $playerInfo = [PSCustomObject]@{
            Name = $teamMember
            TotalPositionValue = $totalPositionValue
        }
        $AvailablePlayers.Add($playerInfo) | Out-Null  # Add each playerInfo object to the list
    }
    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - There are $($AvailablePlayers.Count) AvailablePlayers"


$InfielderUsage = @()
$i = 0  # Initialize the counter variable
# Loop until either all infield positions are filled or there are no more available players
while ($InfielderUsage.Count -lt 5 -and $AvailablePlayers.Count -gt 0) {
    $selectedPlayers = $AvailablePlayers | Sort-Object -Property TotalPositionValue -Descending | Select-Object -Last 5
    foreach ($InningItem in $Innings | Where-Object { $_.inning -eq $Inning -and $InfieldPositions -contains $_.Position }) {
        if (-not $InningItem.player -and $InfieldPositions -contains $InningItem.Position) {
            # Assign the selected player to the current infield position
            $InningItem.player = $selectedPlayers[$i].Name
            $AvailablePlayers.Remove($selectedPlayers[$i].Name)
            # Find the index of the selected player in $AvailablePlayers
            $playerIndex = $AvailablePlayers.IndexOf($selectedPlayers[$i])

            # Remove the player from $AvailablePlayers using the index
            $AvailablePlayers.RemoveAt($playerIndex)
            $i++
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Inning $($InningItem.inning) - Player $($InningItem.player) - $($InningItem.Position)"

            $InfielderUsage += $selectedPlayers
        }
    }

}
Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $($AvailablePlayers.Count)"
    if ($InfielderUsage.Count -lt 5) {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No suitable players found for all infield positions."
    }

$OutfielderUsage = @()
$i = 0  # Initialize the counter variable
# Loop until either all infield positions are filled or there are no more available players
while ($OutfielderUsage.Count -lt 3 -and $AvailablePlayers.Count -gt 0) {
    $selectedPlayers = $AvailablePlayers | Sort-Object -Property TotalPositionValue | Select-Object -Last 3
    # Assign infield players to their positions
    foreach ($InningItem in $Innings | Where-Object { $_.inning -eq $Inning -and $OutfieldPositions -contains $_.Position}) {
        If (-not $InningItem.player ) {
            $InningItem.player = $selectedPlayers[$i].Name 
            $i++
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Inning $($InningItem.inning) - Player $($InningItem.player) - $($InningItem.Position)"
            $OutfielderUsage += $selectedPlayers[$i].Name 
        }
    }
}
     if ($OutfielderUsage.Count -lt 3) {
         Write-Verbose -Message "[$($MyInvocation.MyCommand)] - No suitable players found for all infield positions."
     }

    
    $Innings

}


function Set-UnassignedPlayer {
    <#
.SYNOPSIS
Checks for unassigned players in a specific inning and assigns them to the Bench One position.

.DESCRIPTION
This function checks for unassigned players in a specific inning and assigns them to the Bench One position. It takes an array of innings, an array of team members, and an optional inning parameter (default value is 6). It then identifies unassigned players and assigns them to the Bench One position.

.PARAMETER Innings
An array of innings, each containing 'Player', 'Inning', 'Position', and 'PositionValue' properties.

.PARAMETER TeamMembersList
An array of team members' names.

.PARAMETER Inning (Optional)
The specific inning to check for unassigned players and assign them to the Bench One position. Default value is 6.

.EXAMPLE
$innings = @(
    [PSCustomObject]@{ Inning = 6; Player = "UnAssigned"; Position = ""; PositionValue = 0 },
    [PSCustomObject]@{ Inning = 6; Player = "UnAssigned"; Position = ""; PositionValue = 0 },
    [PSCustomObject]@{ Inning = 6; Player = "UnAssigned"; Position = ""; PositionValue = 0 }
)
$teamMembersList = @("Player1", "Player2", "Player3", "Player4", "Player5", "Player6")
$result = Set-UnassignedPlayer -Innings $innings -TeamMembersList $teamMembersList -Inning 6
$result

.NOTES
Author: Jason Gebhart
Date: August 3, 2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $TeamMembersList,
        [Parameter(Position=2,Mandatory=$false,ValueFromPipeline = $true)]
        $Inning = 6
    )

    Begin
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] Checking for UnAssigned Players --- Inning $Inning"
    }
    Process
    {
        #Find if a position is Unassigned this inning and create an object
        $Unassigned = $Innings | Where-Object {$_.inning -eq $Inning -and $_.Player -eq "UnAssigned"}
        If ($Unassigned.count -gt 1) {
             Write-Verbose -Message "[$($MyInvocation.MyCommand)] Unassigned Players $($Unassigned.count)"
        } else {
            Write-Verbose -Message "[$($MyInvocation.MyCommand)] Unassigned Position - $($Unassigned.Position)"
        }

        #Build an object of players that have been assigned this inning
        $AssignedPlayer = $Innings | Where-Object {$_.inning -eq $Inning} | Select-Object -Property Player

        # Create a simple array to match $TeamMemberList type
        # This will remove the header row so that a compare can be completed 
        $AssignedPlayerList = @()
        Foreach ($a in $AssignedPlayer) {$AssignedPlayerList += $a.Player}

        # Check if Unassigned
        If ($Unassigned -ne $null) {
            # Compare the Assigned players to the team members list to determine who has not been assigned a position.
            $UnassignedPlayer = Compare-Object $($AssignedPlayerList | Sort-Object) $($TeamMembersList | Sort-Object) -PassThru |
                Where-Object {$_.SideIndicator -eq '=>'}  
            
            $x=0
             Foreach ($item in $Innings | Where-Object {$_.inning -eq $Inning -and $_.Player -eq "UnAssigned"}) {
                If ($UnassignedPlayer.count -gt 1) {
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - X is equal to $x"
                    $item.player = $UnassignedPlayer[$x]
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] Unassigned Player $($UnassignedPlayer[$x])"
                } else {
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - X is equal to $x"
                    $item.player = $UnassignedPlayer
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] Unassigned Player $($UnassignedPlayer)"
                }
                ++$x
            }             
        }
    }
    End
    {
        $innings
    }
}

function Set-FirstInning {
    <#
    .SYNOPSIS
    Assigns players to positions for the first inning.

    .DESCRIPTION
    This function takes a list of team members and an array of innings as input. It assigns players to positions for the first inning based on certain conditions.

    .PARAMETER TeamMembersList
    An array of team members.

    .PARAMETER Innings
    An array of innings, each containing a 'Player', 'Inning', 'Position', and 'PositionValue' property.

    .EXAMPLE
    $teamMembers = "Player1", "Player2", "Player3", "Player4", "Player5"
    $innings = @(
        [PSCustomObject]@{ Inning = 1; Position = "Catcher"; PositionValue = 1 },
        [PSCustomObject]@{ Inning = 1; Position = "Pitcher"; PositionValue = 1 },
        [PSCustomObject]@{ Inning = 1; Position = "First Base"; PositionValue = 2 },
        [PSCustomObject]@{ Inning = 1; Position = "Second Base"; PositionValue = 2 },
        [PSCustomObject]@{ Inning = 1; Position = "Third Base"; PositionValue = 2 },
        [PSCustomObject]@{ Inning = 1; Position = "Shortstop"; PositionValue = 2 },
        [PSCustomObject]@{ Inning = 1; Position = "Left Field"; PositionValue = 3 },
        [PSCustomObject]@{ Inning = 1; Position = "Center Field"; PositionValue = 3 },
        [PSCustomObject]@{ Inning = 1; Position = "Right Field"; PositionValue = 3 },
        [PSCustomObject]@{ Inning = 1; Position = "Bench One"; PositionValue = 0 },
        [PSCustomObject]@{ Inning = 1; Position = "Bench Two"; PositionValue = 0 },
        [PSCustomObject]@{ Inning = 1; Position = "Bench Three"; PositionValue = 0 },
        [PSCustomObject]@{ Inning = 1; Position = "Bench Four"; PositionValue = 0 }
    )
    $result = Set-FirstInning -TeamMembersList $teamMembers -Innings $innings
    $result

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
        $TeamMembersList,
        [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
        $Innings
    )
    Begin
    {
        $Outfield = @("Left Field","Right Field","Center Field")
        [System.Collections.ArrayList]$TempTeamMembers = $TeamMembersList
    }
    Process
    {
        # Remove a player from list if he is already assigned to a position for that inning
        Foreach ($Inning in $Innings | Where-Object {$_.inning -eq 1}) {
            If ($Inning.player) {
                $TempTeamMembers.Remove($Inning.player)
            }
        }
        Foreach ($Inning in $Innings | Where-Object {$_.inning -eq 1 -and $_.position -notmatch "bench*"}) {
            If (-not($Inning.player)) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Inning $($Inning.inning)"
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Filling Position for $($Inning.Position)"
                $TempPlayer = Get-Random -InputObject $TempTeamMembers
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - TempPlayer: $TempPlayer"
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - PositionValue: $($Inning.PositionValue)"
                If ($Inning.PositionValue -le 1) {
                    Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assigning an Outfield position: $($Inning.Position)"
                    Switch ($TeamMembersList.count) {
                        7
                        {
                            If($Inning.Position -ne "Center Field") {
                                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Too Few Players for this outfield position"
                                $TempPlayer = "UnAssigned"
                            }
                        }
                        8 
                        {
                            If($Inning.Position -eq "Center Field") {
                                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Too Few Players for this outfield position"
                                $TempPlayer = "UnAssigned"
                            }
                        }
                        default
                        {
                            #$TempPlayer = Get-Random -InputObject $TempTeamMembers
                            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - TempPlayer: $TempPlayer"
                        }
                    }
                    If ($TempPlayer -ne "UnAssigned"){
                        $i = 0 
                        do
                            {
                            $NextInningPosition = Get-PlayerPositionValueInInning -player $TempPlayer -Innings $Innings -Inning (1+1)
                            Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Next inning position: $($NextInningPosition.position)"
                            If($NextInningPosition.position -match "bench*" -or $Outfield -contains $NextInningPosition.position) {
                                $TempPlayer = Get-Random -InputObject $TempTeamMembers
                                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - New Player: $TempPlayer"
                            }
                            ++$i
                        }
                        until ($NextInningPosition.position.name -notmatch "bench*" -or $i -eq 5)
                    }
                }
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Player: $TempPlayer"
                $Inning.player = $TempPlayer
                $TempTeamMembers.Remove($TempPlayer)
            }
        }
    }
    End
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - ******************"
        $Innings
    }
}


function Test-PlayedPosition {
    <#
    .SYNOPSIS
    Checks if a player has already played a specific position.

    .DESCRIPTION
    This function takes a player name, an array of innings, and a position as input. It checks if the player has already played the specified position in any of the innings.

    .PARAMETER Name
    The name of the player to check.

    .PARAMETER Innings
    An array of innings, each containing a 'Player' and 'Position' property.

    .PARAMETER Position
    The position to check if the player has played.

    .EXAMPLE
    $player1 = [PSCustomObject]@{ Player = 'John Doe'; Position = 'Catcher' }
    $player2 = [PSCustomObject]@{ Player = 'Jane Smith'; Position = 'Pitcher' }
    $innings = $player1, $player2
    $result = Test-PlayedPosition -Name 'John Doe' -Innings $innings -Position 'Catcher'
    if ($result) {
        Write-Output "John Doe has already played Catcher."
    } else {
        Write-Output "John Doe has not played Catcher yet."
    }

    .NOTES
    Author: Jason Gebhart
    Date: [Insert Today's Date]
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Name,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        [array]$Innings,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Position
    )

    Process {
        if ($Innings -isnot [array]) {
            throw "PlayerInnings should be an array of innings."
        }

        foreach ($playerInning in $Innings) {
            if ($playerInning.Player -eq $Name -and $playerInning.Position -eq $Position) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $Name has already played $Position."
                return $true
            }
        }

        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $Name has not played $Position."
        return $false
    }
}


function New-Innings {
    <#
    .SYNOPSIS
    Creates a collection of innings with specified baseball positions.

    .DESCRIPTION
    This function generates a collection of innings based on the given baseball positions.
    Each inning contains player data for a specific position, and the number of innings can be specified.

    .PARAMETER BaseballPositions
    The array of baseball positions for which the innings need to be created.

    .PARAMETER NumberOfInnings
    The number of innings to generate. Default is 6.

    .EXAMPLE
    $positions = @(
        [PSCustomObject]@{ Name = 'Catcher'; Value = 1.7; Number = 2 },
        [PSCustomObject]@{ Name = 'Pitcher'; Value = 1.7; Number = 1 },
        [PSCustomObject]@{ Name = 'Left Field'; Value = 1.0; Number = 7 }
    )
    $innings = New-Innings -BaseballPositions $positions -NumberOfInnings 9

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $BaseballPositions,

        [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
        $NumberOfInnings = 6
    )

    Begin {
        $Innings = [System.Collections.ArrayList]@()
    }

    Process {
        for ($x = 1; $x -le $NumberOfInnings; $x++) {
            foreach ($position in $BaseballPositions) {
                $Innings.Add([pscustomobject]@{
                    Player = $null
                    Inning = $x
                    Position = $position.Name 
                    PositionValue = $position.Value
                    PositionNumber = $position.Number
                    Jersey = $null
                })
            }
        }
    }

    End {
        $Innings
    }
}


function New-PitcherFromRandom {
    <#
    .SYNOPSIS
    Generates a collection of pitchers from a randomized list of team members for multiple innings.

    .DESCRIPTION
    This function takes a list of team members and randomly selects players to be pitchers for each inning.
    The number of pitchers to generate is based on the specified number of innings.

    .PARAMETER TeamMembersList
    An array of team members from which pitchers will be randomly selected.

    .PARAMETER NumberOfInnings
    The number of innings for which pitchers need to be generated.

    .EXAMPLE
    $teamMembers = @("Player 1", "Player 2", "Player 3", "Player 4", "Player 5")
    $numberOfInnings = 9
    $pitchers = New-PitcherFromRandom -TeamMembersList $teamMembers -NumberOfInnings $numberOfInnings

    .NOTES
    Author: Jason Gebart
    Date: 8/3/20023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $TeamMembersList,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        $NumberOfInnings
    )

    Begin {
        $TeamMembersList = $TeamMembersList | Sort-Object {Get-Random}
        $Pitchers = @()
    }

    Process {
        for ($i = 1; $i -le $NumberOfInnings; $i++) {
            $player = $TeamMembersList[$i - 1]
            $Pitchers += [pscustomobject] @{
                Name = $player
                Inning = $i
                Position = "Pitcher"
            }
        }
    }

    End {
        $Pitchers
    }
}



function New-PitcherList {
    <#
    .SYNOPSIS
    Creates a list of pitcher names.

    .DESCRIPTION
    This function takes an array of pitcher objects as input and extracts their names to create a list of pitcher names.

    .PARAMETER Pitchers
    An array of pitcher objects, each containing a 'Name' property.

    .EXAMPLE
    $pitcher1 = [pscustomobject]@{ Name = 'John Doe' }
    $pitcher2 = [pscustomobject]@{ Name = 'Jane Smith' }
    $pitcherList = New-PitcherList -Pitchers $pitcher1, $pitcher2
    $pitcherList

    .NOTES
    Author: Jason Gebhart
    Date: August, 3 2023
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)]
        $Pitchers
    )

    Begin {
        $ListOfPitchers = @()
    }

    Process {
        Foreach ($pitch in $pitchers) {
            $ListOfPitchers += $pitch.Name
        }        
    }

    End {
        [System.Collections.ArrayList]$ListOfPitchers
    }
}

function New-TeamMemberFromXML {
    <#
    .SYNOPSIS
    Creates team member objects from an XML file.

    .DESCRIPTION
    This function reads an XML file and extracts team member information from it. It takes the XML file path as input and returns custom objects containing team member details such as Name, Available, Jersey, Category, Batting, and Fielding.

    .PARAMETER Path
    The path to the XML file containing team member information.

    .EXAMPLE
    $teamMembers = New-TeamMemberFromXML -Path "C:\Path\To\TeamMembers.xml"
    $teamMembers

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
     #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("XMLPath")]
        [string]$Path
    )

    try {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - XML: $Path"
        $XMLDoc = [xml](Get-Content -Path $Path)

        if ($XMLDoc.team -is [System.Xml.XmlElement] -and $XMLDoc.team.members.member -is [System.Collections.IEnumerable]) {
            $Results = foreach ($member in $XMLDoc.team.members.member) { 
                [pscustomobject]@{
                    Name = $member.Name
                    Available = $member.Available
                    Jersey = $member.Jersey
                    Category = $member.category
                    Batting = $member.Batting
                    Fielding = $member.fielding
                }
            }

            return $Results
        } else {
            throw "Invalid XML structure: The 'team' element or 'members' element is missing or not in the expected format."
        }
    }
    catch {
        Write-Warning "An error occurred while processing the XML file: $_"
    }
}

function New-PitcherFromXML {
    <#
    .SYNOPSIS
    Creates pitcher objects from an XML file.

    .DESCRIPTION
    This function reads an XML file and extracts pitcher information from it. It takes the XML file path as input and returns custom objects containing pitcher details such as Name, Inning, and Position.

    .PARAMETER Path
    The path to the XML file containing pitcher information.

    .EXAMPLE
    $pitchers = New-PitcherFromXML -Path "C:\Path\To\Pitchers.xml"
    $pitchers

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("XMLPath")]
        [string]$Path
    )

    try {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - XML: $Path"
        $XMLDoc = [xml](Get-Content -Path $Path)

        if ($XMLDoc.team -is [System.Xml.XmlElement] -and $XMLDoc.team.pitchers.pitcher -is [System.Collections.IEnumerable]) {
            $Results = foreach ($pitcher in $XMLDoc.team.pitchers.pitcher) { 
                [pscustomobject]@{
                    Name = $pitcher.Name
                    Inning = $pitcher.Inning
                    Position = $pitcher.Position
                }
            }

            return $Results
        } else {
            throw "Invalid XML structure: The 'team' element or 'pitchers' element is missing or not in the expected format."
        }
    }
    catch {
        Write-Warning "An error occurred while processing the XML file: $_"
    }
}

function New-PositionFromXML {
    <#
    .SYNOPSIS
    Creates position objects from an XML file.

    .DESCRIPTION
    This function reads an XML file and extracts position information from it. It takes the XML file path as input and returns custom objects containing position details such as Name, Inning, and Position.

    .PARAMETER Path
    The path to the XML file containing position information.

    .EXAMPLE
    $positions = New-PositionFromXML -Path "C:\Path\To\Positions.xml"
    $positions

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("XMLPath")]
        [string]$Path
    )

    try {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - XML: $Path"
        $XMLDoc = [xml](Get-Content -Path $Path)

        if ($XMLDoc.team -is [System.Xml.XmlElement] -and $XMLDoc.team.positions.assignment -is [System.Collections.IEnumerable]) {
            $Results = @()

            foreach ($position in $XMLDoc.team.positions.assignment) { 
                $Results += [pscustomobject]@{
                    Name = $position.Name
                    Inning = $position.Inning
                    Position = $position.Position
                }
            }

            return $Results
        } else {
            throw "Invalid XML structure: The 'team' element or 'positions' element is missing or not in the expected format."
        }
    }
    catch {
        Write-Warning "An error occurred while processing the XML file: $_"
    }
}


function New-JobFromXML {
    <#
    .SYNOPSIS
    Creates job objects from an XML file.

    .DESCRIPTION
    This function reads an XML file and extracts job information from it. It takes the XML file path as input and returns a custom object containing job details such as ThirdBaseCoach, FirstBaseCoach, PitchCounterOne, PitchCounterTwo, LineupCoach, BallsStrikesOutsCoach, and ScoreKeeper.

    .PARAMETER Path
    The path to the XML file containing job information.

    .EXAMPLE
    $jobs = New-JobFromXML -Path "C:\Path\To\Jobs.xml"
    $jobs

    .NOTES
    Author: Jason Gebhart
    Date: August 3, 2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("XMLPath")]
        [string]$Path
    )

    try {
        Write-Verbose -Message "[$($MyInvocation.MyCommand)] - XML: $Path"
        $XMLDoc = [xml](Get-Content -Path $Path)

        if ($XMLDoc.dugout -is [System.Xml.XmlElement]) {
            $jobs = $XMLDoc.dugout.jobs
            foreach ($job in $jobs) { 
                [pscustomobject]@{
                    ThirdBaseCoach = $job.ThirdBaseCoach 
                    FirstBaseCoach = $job.FirstBaseCoach       
                    PitchCounterOne = $job.PitchCounterOne
                    PitchCounterTwo = $job.PitchCounterTwo   
                    LineupCoach = $job.LineupCoach  
                    BallsStrikesOutsCoach = $job.BallsStrikesOutsCoach
                    ScoreKeeper = $job.ScoreKeeper
                }
            }
        } else {
            throw "Invalid XML structure: The 'dugout' element is missing or not in the expected format."
        }
    }
    catch {
        Write-Warning "An error occurred while processing the XML file: $_"
    }
}

Function Get-GameInfoFromCSV {
    [Cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("Date")]
        [datetime]$TargetDate,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$ScheduleCsv,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$RosterXml
    )

    Begin {
        # Extract team name from XML
        $xmlContent = Get-Content -Path $RosterXml -Raw
        $xml = [xml]$xmlContent
        $teamNode = $xml.SelectSingleNode('//team')
        $TeamName = $teamNode.friendlyname

        if ($VerbosePreference -eq 'Continue') {
            Write-Verbose "TeamName - $TeamName"
        }
    }

    Process {
        $schedule = Import-Csv -Path $ScheduleCsv |
            Where-Object { $null -ne $_.Date -and $_.Date -ne '' } |
            ForEach-Object {
                $_.Date = $_.Date -as [datetime]
                $_
            }
        foreach ($day in $schedule) {
            if ($VerbosePreference -eq 'Continue') {
                Write-Verbose $day
            }
        }

        $futureGames = $schedule | Where-Object { $_.Date -ge $TargetDate } -ErrorAction Continue
        if ($futureGames.Count -eq 0) {
            Write-Warning "No future games found after $TargetDate"
            return
        }

        foreach ($futureGame in $futureGames) {
            if ($VerbosePreference -eq 'Continue') {
                Write-Verbose "GameDate - $($futureGame.Date)"
            }
        }

        $nextGame = $futureGames | Sort-Object -Property Date | Select-Object -First 1
        if ($VerbosePreference -eq 'Continue') {
            Write-Verbose "NextGame - $nextGame"
        }

        $isHomeTeam = $nextGame.'Home' -match $TeamName

        if ($isHomeTeam) {
            if ($VerbosePreference -eq 'Continue') {
                Write-Verbose "We are the Home Team"
            }
            $homeTeam = $TeamName
            $awayTeam = $nextGame.'Visitor'
        } else {
            if ($VerbosePreference -eq 'Continue') {
                Write-Verbose "We are the Away Team"
            }
            $homeTeam = $nextGame.'Home'
            $awayTeam = $TeamName
        }

        # Output the result
        [pscustomobject]@{
            Location = $nextGame.Location
            StartTime = $nextGame.'Start Time'
            GameDate = $nextGame.Date.ToString("MM-dd-yyyy")
            HomeTeam = $homeTeam
            AwayTeam = $awayTeam
        }
    }    
}




function Get-PositionAbbreviation {
    <#
    .SYNOPSIS
    Gets the abbreviation for a baseball position.

    .DESCRIPTION
    This function retrieves the abbreviation for a specified baseball position. It can be used to convert
    full position names to their corresponding abbreviations.

    .PARAMETER Position
    The full name of the baseball position for which you want to get the abbreviation.

    .EXAMPLE
    $position = "Catcher"
    $abbreviation = Get-PositionAbbreviation -Position $position
    # Output: "C"

    .NOTES
    Author: Your Name
    Date: Today's Date
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("FullName","FullPositionName")]
        [string]$Position
    )

    Begin {
        $Abbreviations = @{
            "Left Field" = "LF"
            "Center Field" = "CF"
            "Right Field" = "RF"
            "Catcher" = "C"
            "First Base" = "1B"
            "Second Base" = "2B"
            "Third Base" = "3B"
            "Short Stop" = "SS"
            "Pitcher" = "P"
            "Bench One" = "X"
            "Bench Two" = "X"
            "Bench Three" = "X"
            "Bench Four" = "X"
        }
    }

    Process {
        if ($Abbreviations.ContainsKey($Position)) {
            $PositionAbbreviation = $Abbreviations[$Position]
        } else {
            Write-Warning "Position '$Position' not found in the abbreviation list."
            $PositionAbbreviation = $Position
        }
    }

    End {
        $PositionAbbreviation
    }
}

Function Get-LineupNEWCode {
    <#
    .SYNOPSIS
    Generates a baseball lineup based on the provided team members and innings data.

    .DESCRIPTION
    This function generates a baseball lineup using the given team members, innings data, and lineup method.
    It allows you to create lineups using different methods such as Random, Bench, Assigned, or TotalValue.

    .PARAMETER TeamMembers
    An array of team members representing players with their name, jersey, and batting order.

    .PARAMETER Innings
    An array containing player data for each inning, including the inning number and the position played.

    .PARAMETER TotalValue
    An array with the total value of each player based on their positions.

    .PARAMETER NumberOfInnings
    The number of innings for which the lineup needs to be generated.

    .PARAMETER LineupMethod
    The method to create the lineup. Valid values are "Random", "Bench", "Assigned", or "TotalValue".

    .EXAMPLE
    $teamMembers = @(
        [PSCustomObject]@{ Name = 'Player 1'; Jersey = '#1'; Batting = 1 },
        [PSCustomObject]@{ Name = 'Player 2'; Jersey = '#2'; Batting = 2 },
        [PSCustomObject]@{ Name = 'Player 3'; Jersey = '#3'; Batting = 3 }
    )
    $innings = @(
        [PSCustomObject]@{ Player = 'Player 1'; Inning = 1; Position = 'Catcher' },
        [PSCustomObject]@{ Player = 'Player 2'; Inning = 1; Position = 'Pitcher' },
        [PSCustomObject]@{ Player = 'Player 3'; Inning = 1; Position = 'Left Field' }
    )
    $totalValue = @(
        [PSCustomObject]@{ Name = 'Player 1'; TotalPositionValue = 1.7 },
        [PSCustomObject]@{ Name = 'Player 2'; TotalPositionValue = 1.7 },
        [PSCustomObject]@{ Name = 'Player 3'; TotalPositionValue = 1.0 }
    )
    $numberOfInnings = 9
    $lineup = Get-Lineup -TeamMembers $teamMembers -Innings $innings -TotalValue $totalValue -NumberOfInnings $numberOfInnings -LineupMethod 'Assigned'

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias("Players")]
        [array]$TeamMembers,

        [Parameter(Mandatory, ValueFromPipeline)]
        [array]$Innings,

        [Parameter(Mandatory, ValueFromPipeline)]
        [array]$TotalValue,

        [Parameter(Mandatory, ValueFromPipeline)]
        [int]$NumberOfInnings,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias("Method")]
        [ValidateSet("Random", "Bench", "Assigned", "TotalValue")]
        [string]$LineupMethod
    )

    Begin {
        $LineUp = @()
    }

    Process {
        foreach ($member in $TeamMembers) {
            $PlayerSchedule = @(
                $innings | Where-Object { $_.Player -eq $member.Name } |
                ForEach-Object {
                    [PSCustomObject]@{
                        Inning = $_.inning
                        Position = Get-PositionAbbreviation -Position $_.position
                    }
                }
            )

            if ($PlayerSchedule) {
                Write-Verbose "Batting: $($member.batting)"
                $Lineup += [PSCustomObject]@{
                    "#" = $member.jersey
                    Name = $member.Name
                    Innings = $PlayerSchedule
                    Batting = [int]$member.batting
                    PositionValue = ($TotalValue | Where-Object { $_.Name -eq $member.Name }).TotalPositionValue
                }
            }
        }

        $properties = @(
            "#" 
            "Name"
        )

        for ($i = 1; $i -le $NumberOfInnings; $i++) {
            $properties += @{
                Expression = { $_.Innings[$i - 1].Position }
            }
        }

        $properties += "Batting"

        switch ($LineupMethod) {
            "Random" {
                Write-Verbose "LineupMethod: Random"
                $NewLineup = $LineUp | Sort-Object { Get-Random } | Select-Object -Property $properties
            }
            "Bench" {
                Write-Verbose "LineupMethod: Bench"
                $Result = @(
                    $LineUp | Where-Object { $_.Innings[0].Position -eq 'X' -and $_.Innings[1].Position -ne "P" }
                    $LineUp | Where-Object { $_.Innings[0].Position -eq 'X' -and $_.Innings[1].Position -eq "P" }
                    $LineUp | Where-Object { $_.Innings[0].Position -ne 'X' } | Sort-Object { Get-Random }
                )
                $NewLineup = $Result | Select-Object -Property $properties
            }
            "Assigned" {
                Write-Verbose "LineupMethod: Assigned"
                $NewLineup = $LineUp | Sort-Object -Property Batting | Select-Object -Property *
            }
            "TotalValue" {
                Write-Verbose "LineupMethod: TotalValue"
                $NewLineup = $LineUp | Sort-Object -Property PositionValue | Select-Object -Property $properties
            }
        }
    }

    End {
        $NewLineup
    }
}
Function Get-Lineup  {
    [Cmdletbinding()]
      param (
      [Parameter(Position=0,Mandatory=$true,ValueFromPipeline = $true)]
          $TeamMembers,
      [Parameter(Position=1,Mandatory=$true,ValueFromPipeline = $true)]
           $innings,
      [Parameter(Position=2,Mandatory=$true,ValueFromPipeline = $true)]
           $TotalValue,
      [Parameter(Position=3,Mandatory=$true,ValueFromPipeline = $true)]
           $NumberOfInnings,
      [Parameter(Position=4,Mandatory=$true,ValueFromPipeline = $true)]
           $LineupMethod
      )
      Begin {
          $LineUp = @()
      }
      Process {
              Foreach ($member in $TeamMembers) {
                  # Create a Hash table for Position by inning
                  $PlayerSchedule = @()
                  Foreach($item in $innings | Where-Object {$_.Player -eq $member.name}){
                      #$PlayerSchedule.add($item.inning,$item.position)
                      $PlayerSchedule += [PSCustomObject]@{
                          Inning = $item.inning
                          Position = Get-PositionAbbreviation -Position $item.position
                      }
                  }
                  If ($PlayerSchedule) {
                      Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Batting: $($member.batting)"
                      $Lineup += [PSCustomObject]@{
                          Name = $member.name
                          Number = $member.jersey
                          Innings = $playerschedule
                          Batting = [int]$member.batting
                          PositionValue = ($TotalValue | Where-Object { $_.Name -eq $member.name} | Select-Object -Property TotalPositionValue).TotalPositionValue
                      }
                  }
              }
              $properties = @(
              "Number"
              "Name"
              @{Name="Inning1"; Expression={$_.Innings[0].position}}
              @{Name="Inning2"; Expression={$_.Innings[1].position}}
              @{Name="Inning3"; Expression={$_.Innings[2].position}}
              @{Name="Inning4"; Expression={$_.Innings[3].position}}
              @{Name="Inning5"; Expression={$_.Innings[4].position}}
              #"Batting"
              )
              If($NumberOfInnings -eq 6) {
                  $properties += @{Name="Inning6";Expression={$_.Innings[5].position}}
              }
              #$LineUp | Sort-Object -Property Batting | Out-GridView 
              #$LineUp | Sort-Object -Property Batting | Select-object -property $properties | Format-table
              #$LineUp | Sort-Object -Property Batting | Select-object -property $properties | Out-GridView
  
              #$LineUp | Sort-Object {Get-Random} | Select-object -property $properties | Out-GridView
              <#
              Foreach ($i in 1..6) {
                  $Innings | Where-Object {$_.Inning -eq $i} | Format-Table *
              }
              #>
              $NewLineup = @()
              switch ($LineupMethod) {
                  "Random"
                   {
                      # Random Lineup
                      Write-Verbose -Message "[$($MyInvocation.MyCommand)] - LineupMethod: Random"
                      $NewLineup = $LineUp | Sort-Object {Get-Random} | Select-object -property $properties 
                   }
                   "Bench"
                   {
                      # Bench Lineup
                      Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Bench"
                      $Result = @()
                      $Result += $LineUp | Where-Object {$_.Innings[0].Position -eq 'X' -and $_.Innings[1].Position -ne "P"}
                      $Result +=  $LineUp | Where-Object {$_.Innings[0].Position -eq 'X' -and $_.Innings[1].Position -eq "P"}
                      $Result += $LineUp | Where-Object {$_.Innings[0].Position -ne 'X'} | Sort-Object {Get-Random}
                      #$Result += $LeadOffHitters + $LeadOffHitterPitcher + $RestOfLineup 
                      $NewLineup = $Result | Select-object -property $properties 
  
                   }
                  "Assigned"
                   {
                       # Assigned Lineup 
                      Write-Verbose -Message "[$($MyInvocation.MyCommand)] - Assigned - Sorting Lineup"
                      $NewLineup = $LineUp | Sort-Object -Property Batting
                      Foreach ($x in $NewLineup ) {Write-Verbose -Message "[$($MyInvocation.MyCommand)] - $($x.name) Batting: $($x.batting)" }
                      $NewLineup = $NewLineup | Select-object -property $properties 
                   }
                  "TotalValue"
                   {
                       # According to positional value.
                       Write-Verbose -Message "[$($MyInvocation.MyCommand)] - TotalValue"
                      $NewLineup = $LineUp | Sort-Object -Property PositionValue | Select-object -property $properties 
                   }
              }
          }
      End {$NewLineup}
  }

#Variables
$PositionNames = @(
"Catcher"
"FirstBase"
"SecondBase"
"ShortStop"
"ThirdBase"
"LeftField"
"CenterField"
"RightField"
"Pitcher"
"BenchOne"
"BenchTwo"
"BenchThree"
"BenchFour"
)
function Get-BaseballConfig {
    <#
    .SYNOPSIS
    Reads and parses the Baseball Configuration file.

    .DESCRIPTION
    This function reads and parses the specified Baseball Configuration file in JSON format.
    It retrieves the contents of the configuration file and converts it into a PowerShell object.

    .PARAMETER BaseballConfig
    The path to the Baseball Configuration file. Default is "baseball.config.json" in the current directory.

    .EXAMPLE
    Get-BaseballConfig -BaseballConfig "C:\Path\to\your\config.json"

    .NOTES
    Author: Jason Gebhart
    Date: 8/3/2023
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [string]$BaseballConfig = "baseball.config.json"
    )
    try {
        Write-Verbose "Baseball Configuration file: $BaseballConfig" 
        Get-Content -Path $BaseballConfig -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to read or parse the configuration file: $_"
    }
}


Export-ModuleMember -Function *
Export-ModuleMember -variable PositionNames