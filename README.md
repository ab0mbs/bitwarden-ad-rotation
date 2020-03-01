# bitwarden-ad-rotation
Scripts to rotate passwords of users in AD and save them to Bitwarden

These scripts are provided as is and are not guaranteed to work

## Bitwarden_Setup.ps1
Run this once before using the password rotation script
- Asks for Bitwarden credentials and saves a session key to the config
- Will log out and back in if already logged in

## Bitwarden_Config.json
- Sets path to Bitwarden CLI
- Sets path to log output file
- Saves session key for continued use
- Sets AD domain
- Sets password length
- Define users and bitwarden items to update

## Bitwarden_Password_Rotation.ps1
- Loops through the users defined
- Gets the items in bitwarden. (They need to be created there first and have unique names)
- Generates a new password
- Saves password to Bitwarden
- Sets password in AD
- Logs success and errors to log path
