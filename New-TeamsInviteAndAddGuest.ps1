<#
.Synopsis
   Send an invite and add a guest to a team.
.DESCRIPTION
   Function will generate a standard Teams guest invite and add the guest account to the team.
.NOTES
   Until someone more experienced works on this, you will need to be familiar with your browser's developer tools to use this function.
   In DevTools, you will extract three values: Request URL (API URL) and Authorization (Bearer token).
   You can derive the two GUIDs in the Request URL from a link to the General channel, but I found different tenants used different base URLs.
.EXAMPLE
   New-TeamsInviteAndAddGuest -Email 'sally@contoso.io' -DisplayName 'Sally Simon' -ApiUrl 'https://...' -BearerToken 'Bearer ej8if7hs...'

   # Add Sally Simon (sally@contoso.io) to a team.
.EXAMPLE
   $users = Import-Csv -Path .\NewGuests.csv ( "Email" and "DisplayName" as column headers).
   $api = 'https://teams.microsoft.com/api/mt/amer/beta/teams/19:a57f1cb8...@thread.skype/a76e2.../inviteAndAddGuest'
   $bearer = 'Bearer eyJ7tX9IYOb...'
   foreach ($user in $users) {
      New-TeamsInviteAndAddGuest -Email $user.Email -DisplayName $user.DisplayName -ApiUrl $api -BearerToken $bearer
   }

   # Add an Excel file of new guests to a team.
.PARAMETER Email
   Authentication email address.
.PARAMETER DisplayName
   Name to display for the guest.
.PARAMETER ApiUrl
   URL to the Teams inviteAndAddGuest API for the specific team (from browser DevTools).
.PARAMETER BearerToken
   Bearer authentication token (from browser DevTools).
.PARAMETER Delay
   Delay in milliseconds between API calls.
#>
function New-TeamsInviteAndAddGuest {
   [CmdletBinding(SupportsShouldProcess = $true,
      PositionalBinding = $false,
      ConfirmImpact = 'Medium')]
   [Alias()]
   [OutputType([String])]
   Param
   (
      # UPN account login for the user
      [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [String[]]
      $Email,

      # Display name for the account
      [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [String[]]
      $DisplayName,

      # URL link to the API
      [Parameter(Position = 2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ApiUrl,

      # Authorization Bearer token (from browser devtools)
      [Parameter(Position = 3, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $BearerToken,

      # Delay each API call by a number of milliseconds.
      [Parameter(Position = 5, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [ValidateRange(1, 10000)]
      [int]
      $Delay
   )

   Begin {
      $BearerToken = $BearerToken -replace 'Bearer ', ''
      $ContentType = 'application/json'
      $Headers = @{
         'authorization' = "Bearer $BearerToken"
      }
   }
   Process {
      if ($pscmdlet.ShouldProcess("$DisplayName <$Email>", 'Invite and Add Guest')) {

         $Payload = @"
{"emailAddress":"$Email","displayName":"$DisplayName","userType":"Guest"}
"@
         $Body = $Payload
         $Params = @{
            Method      = 'Put'
            Uri         = $ApiUrl
            Body        = $Body
            ContentType = $ContentType
            Headers     = $Headers
         }
         try {
            $Result = Invoke-RestMethod @Params
            $Result.value
         }
         catch {}

         if ($Delay -gt 0) {
            Start-Sleep -Milliseconds $Delay
         }
      }
   }
   End {
   }
}
