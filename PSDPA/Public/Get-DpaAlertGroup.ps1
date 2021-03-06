<#

.SYNOPSIS
Gets alert groups from DPA.

.DESCRIPTION
Gets alert groups from DPA that include associated alerts and monitors.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaAlertGroup -AlertGroupName 'SQL'

Gets the "SQL" alert group

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Get-DpaAlertGroup {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByAlertGroupId')]
        [int[]] $AlertGroupId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $AlertGroupName,

        [Parameter()]
        [switch] $EnableException
    )

    process {
        $alertGroups = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByAlertGroupId') {
            foreach ($retrieveAlertGroupId in $AlertGroupId) {
                $endpoint = "/alert-groups/$retrieveAlertGroupId"

                try {
                    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
                    $alertGroups += New-Object -TypeName 'AlertGroup' -ArgumentList $response.data
                } catch {
                    Stop-PSFFunction -Message "Invalid AlertGroupId" -ErrorRecord $_ -EnableException $EnableException
                }
            }
        } else {
            # get all the alert groups
            $endpoint = '/alert-groups'

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'

            # filter by name if applicable
            if (Test-PSFParameterBinding -ParameterName 'AlertGroupName') {
                $response = $response.data | Where-Object { $_.name -in $AlertGroupName }
            } else {
                $response = $response.data
            }

            foreach ($alertGroup in $response) {
                Write-PSFMessage -Level 'Verbose' -Message "Creating alert group for $($alertGroup.id)"
                $alertGroups += New-Object -TypeName 'AlertGroup' -ArgumentList $alertGroup
            }
        }

        $alertGroups
    }
}