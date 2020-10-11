# RADIUS updater
[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://choosealicense.com/licenses/mit/)
[![version](https://img.shields.io/badge/Production%20Version-1.0.0-brightgreen)]()
[![Mainteneance](https://img.shields.io/maintenance/yes/2020?style=plastic)]()
[![Powershell](https://img.shields.io/badge/Powershell-v%205.1-orange)](https://www.microsoft.com/en-us/download/details.aspx?id=54616)

updates radius configuration by removing old entries and adding new ones from a single CSV file

## Installation

1. Install NPS (Network Policy Server) Powershell Library
2. Create Shared Secret for use with new Clients by running Create-sharedSecrets.ps1 

```Powershell
Install-Module -Name NPS -AllowClobber -Force
```

## Features
Update Radius server clients based on a new csv list that will contain all RADIUS clients

## Usage

## Releases
v1.0.0 Released 2020-06-24 - Initital Release 

## Authors
Stephanie Seyler

## license 
[MIT](https://choosealicense.com/licenses/mit/)