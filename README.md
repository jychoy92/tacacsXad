# Ubuntu x TACACS+ Authentication using Active Directory
## Prerequisites
* Windows Server Active Directory Domain Services (Forest level at least 2016)
* Ubuntu Server (16.x, 18.x, 20.x)
* Create the necessary AD Groups 
    + <img width="346" alt="image" src="https://user-images.githubusercontent.com/83763465/166823253-2cff1f0a-7785-4453-9481-77b15caac0e5.png">


## Required Variables
|Variable|Description|
|-------------|-------------|
|ldap_server_ip|LDAP Server IP for TACACS+ Server to do ldap query|
|ldap_base_dn|LDAP Server IP for TACACS+ Server to do ldap query|
|ldap_base_dn|LDAP Search Base DN|
|ldap_auth_username|LDAP Query Service Account's AD ID|
|ldap_auth_password|LDAP Query Service Account's AD Password|
|tacacs_admin_group|Tacacs Admin AD Security Group Name|
|tacacs_helpdesk_group|Tacacs Helpdesk AD Security Group Name|
|tacacs_readonly_group|Tacacs ReadOnly AD Security Group Name|
|tacacs_encryption_key|Tacacs Encryption Key|
|network_mgmt_subnet|Network Devices Management Subnet|

---

## TACACS+  Installation

You can install the TACACS+ using the BASH script by running the following command:
```
wget https://github.com/jychoy92/tacacsXad/raw/main/install.sh -O install.sh; bash install.sh
```
This script will prompt you for the required variables listed in the Required Variable Settings section.

## TACACS+ Troubleshooting

### Control of TACACS+ services
```
sudo systemctl status tac_plus.service
sudo systemctl start tac_plus.service
sudo systemctl stop tac_plus.service
sudo systemctl restart tac_plus.service
```

### Verify if TACACS+ log folder set to permission 755
```
stat --format '%a' /var/log/tac_plus
```

### Verify MAVIS packages are working correctly
```
/usr/local/lib/mavis/mavis_tacplus_ldap.pl < /dev/null
>> OUTPUT <<
Default server type is 'tacacs_schema'. You *may* need to change that to 'generic' or 'microsoft'.
LDAP_HOSTS not defined at /usr/local/lib/mavis/mavis_tacplus_ldap.pl line 277, <DATA> line 755.
```
If there are error messages saying “Can’t locate Net/LDAP.pm in @INC”, you need to double-check the configure and make commands at the beginning of the guide. Make sure they all completed successfully without any errors.

### Verify if TACACS+ config is configure correctly
```
/usr/local/sbin/tac_plus -P /etc/tac_plus/tac_plus.cfg
```

### Verify TACACS+ service is authentication against Active Directory
```
/usr/local/bin/mavistest -d -1 /etc/tac_plus/tac_plus.cfg tac_plus TACPLUS <ad_user> <ad_password>

>> OUTPUT <<
{{ bunch of debug output ...}}
Input attribute-value-pairs:
TYPE                TACPLUS
TIMESTAMP           mavistest-21804-1546360707-0
USER                <ad_user>
PASSWORD            <ad_password>
TACTYPE             AUTH
Output attribute-value-pairs:
TYPE                TACPLUS
TIMESTAMP           mavistest-21804-1546360707-0
USER                <ad_user>
RESULT              ACK
PASSWORD            <ad_password>
SERIAL              OwS74pPKAjcEH89PojinNQ=
DBPASSWORD          password123$
TACMEMBER           "TACACS-Admin"
TACTYPE             AUTH
```
From the output above, look specifically at the RESULT output and the TACMEMBER output.  These should be “ACK” in the RESULT field, which means Active Directory responded and was successful, and the TACMEMBER value should match the security group associated with the user account. If you got NACK, BFD, or ERR in the RESULT field, that means something went wrong. You’ll want to double-check your Active Directory environment variables in the tac_plus.cfg file.

## Reference
* https://www.datai.net/article/tacacs-linux-auth-with-active-directory
* https://git.datai.net/sp-devops/aaa-server
* https://www.pro-bono-publico.de/projects/tac_plus.html
