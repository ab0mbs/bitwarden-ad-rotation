# Get current directory or script start path
if ($PSScriptRoot) {
    $dir = $PSScriptRoot
} else {
    $dir = Get-Location
}

# Get the credentials
$cred = Get-Credential

# Load the config file
$config = Get-Content -Path "$dir\Bitwarden_Config.json" | ConvertFrom-Json

# Save the bitwarden path to a variable
$bw = $config.bitwarden_path

# Logout to invalidate any currently logged in sessions
& $bw logout

# Login to Bitwarden
$sessionKey = & $bw login $($cred.GetNetworkCredential().UserName) $($cred.GetNetworkCredential().Password) --raw

# Save session key to config
$config.session_key = $sessionKey

# Save config to file
$config | ConvertTo-Json | Set-Content -Path "$dir\Bitwarden_Config.json" -Force
