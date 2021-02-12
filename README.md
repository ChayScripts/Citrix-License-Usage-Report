# Citrix-License-Usage-Report

License Usage Report and Email Alert for On-Prem Citrix Sites.

## Description

This script allows you to report citrix license usage and email when licenses are less than 10%.

### Prerequisites

Server that you run this script from, should be able to contact the SMTP server for sending emails. You can send a test email using Send-MailMessage.

### Installing

No installation required.

### Usage

Run this script when required Or, create a scheduled task with this script and run every hour.  

### How does this script work

It pulls license usage from citrix license server and:
* Saves the license usage data to a CSV file and appends it on every run.
* Creates html report with the license data which is saved to CSV file.
* Email if license available percentage is less than 10.

### Who can use

Citrix Admin team.

### Built With

* [PowerShell](https://en.wikipedia.org/wiki/PowerShell) - Powershell

### Authors

* **Tech Guy** - [TechScripts](https://github.com/TechScripts)

### Contributing

Please follow [github flow](https://guides.github.com/introduction/flow/index.html) for contributing.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
