# Bulk Invite and Add Guests to Microsoft Teams

This PowerShell function bulk adds guests to a team and sends standard Teams invitations using the *inviteAndAddGuest* API.

You will need to be familiar with your browser's developer tools (DevTools) to use this function.

Using DevTools, you will extract two values from the initial addition of a guest to your team: **Request URL** (API URL) and **Authorization** (Bearer token).

## Collecting the Parameters

1. In your browser, open Teams to the interface to add a member to your team.
1. Open your browser's developer tools and select the Network tab (F12 or Ctrl+Shift+I).
1. Begin the process to add a guest to your team. You can use one of the new guests you need to add (be sure to set their display name).
1. Just before clicking the **Add** button, on the Network tab of DevTools, click the clear network log icon so the first new entry will be the *inviteAndAddGuest* API call.
1. Click the **Add** button.
1. In the Network tab, find the entry that begins with *inviteAndAddGuest* and click on it.
1. Click on the **Headers** tab.
1. Copy the values for **Request URL** and **Authorization** and save them for use with the function. Treat the Authorization value as a password — do not share it with anyone.

## Examples

### Add a single guest

```powershell
$api = 'https://teams.microsoft.com/api/mt/amer/beta/teams/19:a57f1cb8...@thread.skype/a76e2.../inviteAndAddGuest'
$bearer = 'Bearer eyJ7tX9IYOb...'

New-TeamsInviteAndAddGuest -Email 'sally@contoso.io' -DisplayName 'Sally Simon' -ApiUrl $api -BearerToken $bearer
```

### Bulk add guests from a CSV file

Create a CSV file (e.g., `NewGuests.csv`) with **Email** and **DisplayName** columns:

```
Email,DisplayName
sally@contoso.io,Sally Simon
bob@fabrikam.com,Bob Jones
```

Then pipe the CSV to the function and capture the results:

```powershell
$api = 'https://teams.microsoft.com/api/mt/amer/beta/teams/19:a57f1cb8...@thread.skype/a76e2.../inviteAndAddGuest'
$bearer = 'Bearer eyJ7tX9IYOb...'

$results = Import-Csv -Path .\NewGuests.csv | New-TeamsInviteAndAddGuest -ApiUrl $api -BearerToken $bearer
```

### Review results

```powershell
# Show all results
$results

# Show only failures
$results | Where-Object Status -eq 'Failed'

# Export results to CSV
$results | Export-Csv -Path .\Results.csv -NoTypeInformation
```

## Output

Each call returns an object with the following properties:

| Property    | Description                                       |
|-------------|---------------------------------------------------|
| Email       | Email address of the guest                        |
| DisplayName | Display name for the guest                        |
| Status      | `Success`, `Failed`, or `Skipped`                 |
| Response    | API response data (or error response if failed)   |
| Error       | Error message if the call failed, otherwise null  |
