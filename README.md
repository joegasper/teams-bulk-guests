# Bulk Invite and Add Guests to Microsoft Teams
This PowerShell function can bulk add guests to a team and send a standard Teams invite using the *inviteAndAddGuest* API.

You will need to be familiar with your browser's developer tools (DevTools) to use this function.

Using DevTools, you will extract three values from an initial adding of a guest to your team: Request URL (API URL); Authorization (Bearer token); x-Skypetoken (Skype token).

To collect the three parameters:

1. In your browser, open Teams to the interface to add a member to your team.
1. Open your browser's developer tools and select the network tab (F12 or CTRL+SHIFT+I).
1. Begin the process to add a guest to your team, you can use one of the new guests you need to add (be sure to set their display name!).
1. Just before clicking the Add button to add the guest, on the Network tab of DevTools, click the clear network log icon, so the first new line generated will be to the inviteAndAddGuest API - the activity line you will use to get the three parameters.
1. Now click the Add button.
1. In the Network tab, find the line that begins with *inviteAndAddGuest*, and click on it.
1. You will now see a new set of tabs in DevTools, click on the Headers tab.
1. In the Headers tab, copy the values for *Request URL*, *Authorization*, and *x-Skypetoken* and save them to use later in the function. NOTE: treat the *Authorization* and *x-Skypetoken* values as passwords - do not share them with anyone.
1. Use the example below to call the function for a CSV file of new guests.
1. A successful run of the function will create a new guest in your team, and send them a standard Teams invite as if you and added them manually.

## EXAMPLE

In this example, we will add new guests to a team listed in a CSV file. The CSV file will have two columns: Email and DisplayName. The function will read the CSV file, and for each row, add the guest to the team.

You will set the three parameters as variables, and then call the function for each row in the CSV file.

- $api = *Request URL*
- $bearer = *Authorization*
- $skype = *x-Skypetoken*

```powershell
$users = Import-Csv -Path .\NewGuests.csv ("Email" and "DisplayName" as column headers).
$api = 'https://teams.microsoft.com/api/mt/amer/beta/teams/19.../inviteAndAddGuest'
$bearer = 'Bearer eyJ7tX9IYOb...'
$skype = 'eyJhbG2FP5h...'
foreach ($user in $users) {
    $params = @{
        Email = $user.Email
        DisplayName = $user.DisplayName
        ApiUrl = $api
        BearerToken = $bearer
        SkypeToken = $skype
    }
    New-TeamsInviteAndAddGuest @params
}
```
