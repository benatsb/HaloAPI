Function Set-HaloClientPopup {
    <#
        .SYNOPSIS
            Updates one or more clients via the Halo API.
        .DESCRIPTION
            Function to send a client update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #> 
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing clients.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$ClientPopupNote,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $ClientPopupNote | ForEach-Object {
            if ($null -eq $_.client_id) {
                throw 'Client ID is required.'
            }
            $HaloClientPopupParams = @{
                ClientId = ($_.client_id)
            }
            if (-not $SkipValidation) {
                $ClientExists = Get-HaloClientPopup @HaloClientPopupParams
                if ($ClientExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        #make request template
        #todo: pickup here, the template is off
        <# raw POST examples
            [{"isclientdetails":true,"popup_notes":[{"id":10,"client_id":52,"date_created":"2024-03-14T18:21:56.46","note":"<a href=\"https://halo.sentinelblue.com/ticket?id=0034466&showmenu=false\" style=\"color: #f74c4a\" target=\"_blank\" rel=\"noopener noreferrer\" >0034466</a> : CR in progress : Create VM in Azure Gov and Setup Cloudflare Acccess","dismissable":true,"displaymodal":false,"displayhtml":true,"limitdaterange":false},{"id":9,"client_id":52,"date_created":"2024-03-14T15:00:32.217","note":"<a href=\"https://halo.sentinelblue.com/ticket?id=34415&showmenu=false\" style=\"color: #f74c4a\" target=\"_blank\" rel=\"noopener noreferrer\" >34415</a> : CR in progress : DNS nameserver transition to Cloudflare.","dismissable":true,"displaymodal":false,"displayhtml":true,"limitdaterange":false,"startdate":"1901-01-01T00:00:00.000Z","enddate":"1901-01-01T00:00:00.000Z"}],"id":"52"}]
            [{"isclientdetails":true,"popup_notes":[{"id":10,"client_id":52,"date_created":"2024-03-14T18:21:56.46","note":"<a href=\"https://halo.sentinelblue.com/ticket?id=0034466&showmenu=false\" style=\"color: #f74c4a\" target=\"_blank\" rel=\"noopener noreferrer\" >0034466</a> : CR in progress : Create VM in Azure Gov and Setup Cloudflare Acccess","dismissable":true,"read_status":-1,"displaymodal":false,"displayhtml":true,"limitdaterange":false},{"id":9,"client_id":52,"date_created":"2024-03-14T15:00:32.217","note":"<a href=\"https://halo.sentinelblue.com/ticket?id=34415&showmenu=false\" style=\"color: #f74c4a\" target=\"_blank\" rel=\"noopener noreferrer\" >34415</a> : CR in progress : DNS nameserver transition to Cloudflare.","dismissable":true,"read_status":-1,"displaymodal":false,"displayhtml":true,"limitdaterange":true,"startdate":"2024-03-14T12:00:00.000Z","enddate":"2024-03-16T16:00:00.000Z"}],"id":"52"}]
        #>
        $RequestClientPopupNote = Get-HaloObjectTemplate -Type ClientPopupNote
        $ClientPopupNote | ForEach-Object {
            $_.client_id = $ObjectToUpdate.client_id
            $_.popup_note = $ObjectToUpdate.popup_note
        }
        if ($False -notin $ObjectToUpdate) { 
            if ($PSCmdlet.ShouldProcess($RequestClientPopupNote -is [Array] ? 'Clients' : 'Client', 'Update')) {
                New-HaloPOSTRequest -Object $RequestClientPopupNote -Endpoint 'client'
            }
        } else {
            Throw 'One or more clients was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}