<#
.SYNOPSIS
    Invite and add a guest to a Microsoft Teams team.
.DESCRIPTION
    Sends a standard Teams guest invitation and adds the guest account to a team
    using the inviteAndAddGuest API. Supports pipeline input for bulk operations
    from a CSV file.

    Each API call returns a result object with the guest's email, display name,
    status (Success or Failed), the API response, and any error details.
.NOTES
    You will need your browser's developer tools (DevTools) to obtain the API URL
    and Bearer token. See the project README for step-by-step instructions.
.EXAMPLE
    New-TeamsInviteAndAddGuest -Email 'sally@contoso.io' -DisplayName 'Sally Simon' -ApiUrl $api -BearerToken $bearer

    Add a single guest to a team.
.EXAMPLE
    $results = Import-Csv -Path .\NewGuests.csv | New-TeamsInviteAndAddGuest -ApiUrl $api -BearerToken $bearer

    Bulk add guests from a CSV file with "Email" and "DisplayName" columns.
    Results are captured in $results for review.
.EXAMPLE
    $results = Import-Csv -Path .\NewGuests.csv | New-TeamsInviteAndAddGuest -ApiUrl $api -BearerToken $bearer
    $results | Where-Object Status -eq 'Failed'
    $results | Export-Csv -Path .\Results.csv -NoTypeInformation

    Bulk add guests, review failures, and export all results to CSV.
.PARAMETER Email
    Email address of the guest to invite.
.PARAMETER DisplayName
    Display name for the guest account.
.PARAMETER ApiUrl
    URL to the Teams inviteAndAddGuest API for the specific team.
    Obtain this from the Request URL in browser DevTools.
.PARAMETER BearerToken
    Authorization Bearer token from browser DevTools.
    The "Bearer " prefix is stripped automatically if included.
.INPUTS
    System.Management.Automation.PSObject
        Objects with Email and DisplayName properties (e.g., from Import-Csv).
.OUTPUTS
    System.Management.Automation.PSCustomObject
        Objects with Email, DisplayName, Status, Response, and Error properties.
#>
function New-TeamsInviteAndAddGuest {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Email,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiUrl,

        [Parameter(Mandatory, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$BearerToken
    )

    begin {
        $BearerToken = $BearerToken -replace '^Bearer\s+', ''
        $RequestParams = @{
            Method      = 'Put'
            Uri         = $ApiUrl
            ContentType = 'application/json'
            Headers     = @{ Authorization = "Bearer $BearerToken" }
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("$DisplayName <$Email>", 'Invite and Add Guest')) {
            $Body = @{
                emailAddress = $Email
                displayName  = $DisplayName
                userType     = 'Guest'
            } | ConvertTo-Json -Compress

            try {
                $ApiResponse = Invoke-RestMethod @RequestParams -Body $Body -ErrorAction Stop
                [PSCustomObject]@{
                    Email       = $Email
                    DisplayName = $DisplayName
                    Status      = 'Success'
                    Response    = $ApiResponse
                    Error       = $null
                }
            }
            catch {
                Write-Warning "Failed to add guest '$DisplayName <$Email>': $_"
                [PSCustomObject]@{
                    Email       = $Email
                    DisplayName = $DisplayName
                    Status      = 'Failed'
                    Response    = $_.ErrorDetails.Message
                    Error       = $_.Exception.Message
                }
            }
        }
    }
}
