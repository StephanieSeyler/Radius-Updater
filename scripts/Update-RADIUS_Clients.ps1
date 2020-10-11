# Stephanie Seyler
# 2020-06-24
# v1.0.0

function open-FileBrowser{
    <#
    .SYNOPSIS
        opens a file browser for user to easily select files with a GUI
    .DESCRIPTION
        opens the file browser to defined initial directory and allows selection of file.
        will return the path of the file that was selected by user
    .PARAMETER directory
        Location of the initial directory that will be displayed by the file browser
    .INPUTS
        location of initial directory is optional and will default to C:\
    .OUTPUTS
        path of the file that was selected by user
    .EXAMPLE
        open-fileBrowser -directory $initialDirectory
        open-fileBrowser
    .Notes
        Author: Stephanie Seyler
        Version: 1.0.0
        Date Created: 2019-12-12
        Date Modified: 
    #>
    param([string]$directory = "C:\")
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = $directory}
    $null = $FileBrowser.ShowDialog()
    $FileSelected = $FileBrowser.filename
    return $FileSelected
}

$homeFolder = (split-path -path $PSScriptRoot)
Set-Location -Path $homeFolder
try {
    $errorcount = 0
    $Log = $homefolder +  "\logs\" + (get-date -UFormat "%Y-%m-%d") + " Radius log.csv"
    $dataLog = new-object System.IO.StreamWriter ($log,$false,(new-object System.Text.UTF8Encoding($true)))
    $dataLog.WriteLine('"Date/Time","Type","Information"')
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""BEGIN"",""Begin Logging""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to create new log file""");$errorcount++}

try {
    get-npsRadiusclient | select-object name,address | export-csv "olddataexport.csv"
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Imported previous Radius Client Data and Exported to CSV""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to import previous Radius Client Data and Export to CSV""");$errorcount++}

try {
    $compare = Compare-Object  -ReferenceObject (import-csv "olddataexport.csv") -DifferenceObject (import-csv (open-FileBrowser -directory $homeFolder)) -property "Name", "address"
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Compared Old Data Set to new Data Selected by User""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to Compare and import new data""");$errorcount++}

try {
    $newEntries = $compare | where-object {$_.Sideindicator -eq "=>"}
    $oldEntries = $compare | where-object {$_.Sideindicator -eq "<="}
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Built Data Sets seperating compared Data""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to Seperate Compared Data""");$errorcount++}

try {
    $SharedSecret  = (IMPORT-CLIXML ($homefolder + "\credentials\SharedSecret.xml")).GetNetworkCredential().Password
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Imported Shared Secret Value""")
}
catch {
    Write-Host "Cannot find Shared Secret Value please run Create-SharedSecret.ps1 and Rerun script"
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to Import Shared Secret Value""");$errorcount++
    $datalog.Close()
    exit
}

# Remove old entries from RADIUS Server Configuration
try {
    foreach ($entry in $oldEntries){
        remove-npsradiusclient -name $entry.name
	set-NpsRadiusClient -name $entry.name -enabled $False
        write-host "removed entry name : $($entry.name)"
        $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""RADIUS REMOVE"",""$($entry.name)""")
    }
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Removed Old Entries from RADIUS""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to Remove Old Entries from RADIUS""");$errorcount++}

# Add New entries to RADIUS Server Configuration
try {
    foreach ($entry in $newEntries){
        new-npsradiusclient -address $entry.address -name $entry.name -SharedSecret $SharedSecret
        $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""RADIUS ADD"",""$($entry.name) $($entry.address) $sharedSecret""")
        write-host "Added entry name: $($entry.name) $($entry.address) $sharedSecret"
    }
    $dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""SUCCESS"",""Added New Entries to RADIUS""")
}
catch {$dataLog.writeLine("$(get-date -uformat '%Y%m%d %H%M%S'),""ERROR"",""Failed to add new Entries to RADIUS""");$errorcount++}
$dataLog.close()