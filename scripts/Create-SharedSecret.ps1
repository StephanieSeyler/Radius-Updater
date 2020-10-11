# Stephanie Seyler
# 2020-06-24
# v1.0.0
# Used to build a Shared Secret and export it to the location where the script was ran

$homeFolder= (split-path -path $PSScriptRoot)
Set-Location -Path $homeFolder
Get-Credential  | EXPORT-CLIXML ($homeFolder + "\Credentials\SharedSecret.xml")