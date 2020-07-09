# Terraform and Ansible

Simple Terraform and Ansible templates to manage small, basic infrastructure with Terraform and configuration with Ansible.

## Introduction

## Using Terraform

## Enable https WinRM on Windows Server 2016

As described in [https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#id4], enable WinRM with the following commands:

```
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file
```

After running these `winrm enumerate winrm/config/Listener` should now listen both http and https services running.

## Using Ansible

## Access to the virtual machines

Linux, ssh

Windows, winRM

## Notes

The examples are relatively basic and do not follow all best practises for production quality Terraform and Ansible.

The Terraform templates are "ok", for larger environments one would prefer modules to e.g. launch new vm's so that vm characteristics can be defined as module call parameters.  VM's tend to be complex and different so it's always a challenge to standardize their creation.  `variables.tf` has some parametrization in place, most data is defined here and there is e.g. initial support for using Terraform workspaces as the environment (azure_vnet uses default workspace).  `azure_vm` just defines as object map the basic settings for vm's, in production one might consider some other format or usage pattern.

Ansible playbooks have been implemented as flat, single playbooks and inventory file.  In production it would be recommended to use Ansible roles to configure different task topics and inventory would define the necessary roles for each host.  
Ansible inventory is a static file and in this type of case it should be dynamically built.

One could also combine use of Terraform and Ansible with e.g. running Terraform as Ansible module.
"# ansibleRepo" 
"# ansibleRepo" 
