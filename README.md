# LAMP Stack on SUSE Linux Enterprise Server

## Step 1: Setup the Virtual Network

Deployment Script: *network.json*

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhsirtl%2Flamp-stack-on-sles%2Fmaster%2Fnetwork.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

In this step a Virtual Network gets provisioned that can hold the VMs. The script configures some basic
Network Security Group rules (e.g. SSH access, RDP access, ...).


## Step 2: Provision a LAMP VM

Deployment Script: *azuredeploy.json*

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhsirtl%2Flamp-stack-on-sles%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This script deploys a Virtual Machine with SUSE Linux Enterprise Server and following artifacts:

* Apache Webserver (latest version)
* MySQL 5.7
* PHP 7
* PHP My Admin (into different directory)

The deployment uses the custom script extension with the *install_lamp.sh* Bash-script to do the
necessary configuration.