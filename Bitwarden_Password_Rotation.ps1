# Get current directory or script start path
if ($PSScriptRoot) {
    $dir = $PSScriptRoot
} else {
    $dir = Get-Location
}

# Read in config
$config = Get-Content -Path "$dir\Bitwarden_Config.json" | ConvertFrom-Json

# Save the bitwarden path to a variable
$bw = $config.bitwarden_path

# Sync the vault to make sure it's up to date
& $bw sync --session $config.session_key

# Loop through each account to be configured
foreach ($account in $config.accounts) {
    # Initialize variables
    $item = $null
    $generatedPassword = $null
    $encoded = $null
    $updated = $null

    # Check and see if an item already exists in Bitwarden
    $item = & $bw get item $account.bitwarden_item --session $config.session_key --raw

    # Check if we found the item
    if ($null -ne $item) {
        # Convert item from json
        $item = $item | ConvertFrom-Json

        # Generate password for account
        $generatedPassword = & $bw generate -ulns --length $config.password_length --raw

        # Set new password on the item
        $item.login.password = $generatedPassword

        # Encode the temp data
        $encoded = $item | ConvertTo-Json -Compress | & $bw encode

        # Save to Bitwarden
        $updated = & $bw edit item $item.id $encoded --session $config.session_key --raw

        # Check that the update was successful
        if ($null -ne $updated) {
            $dt = Get-Date -Format s
            Write-Output "$dt - SUCCESS: Updated password in Bitwarden - $($account.bitwarden_item)" | Add-Content -Path $config.log_path

            # Set password in AD
            Try {
                Set-ADAccountPassword -Identity $account.username -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $generatedPassword -Force) -Server $config.ad_domain -ErrorAction Stop
                $dt = Get-Date -Format s
                Write-Output "$dt - SUCCESS: Updated password in AD - $($account.username)" | Add-Content -Path $config.log_path
            } Catch {
                $dt = Get-Date -Format s
                Write-Output "$dt - ERROR: Cannot update password in AD - $($account.username)" | Add-Content -Path $config.log_path
            }
        } else {
            $dt = Get-Date -Format s
            Write-Output "$dt - ERROR: Cannot update password in Bitwarden - $($account.bitwarden_item)" | Add-Content -Path $config.log_path
        }
    } else {
        $dt = Get-Date -Format s
        Write-Output "$dt - ERROR: Cannot get Bitwarden item - $($account.bitwarden_item)" | Add-Content -Path $config.log_path
    }
}
