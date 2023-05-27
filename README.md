# azuki
Shell function to encryp/decrypt a text file with ZIP on Mac. 

# Install
## Load the shell function
Add the following line to your .bashrc or .zshrc.
```
. path/to/azuki/azuki.sh
```    
## Set the password in the keychain
You need to add a password item in the keychain. I assume that its name is "azuki". If you use a different name, you have to change the following line in azuki.sh so that KEYCHAIN_NAME would have the correct name.
Probably, you must add the password item in the "login" keychain. Not sure why, but it does not work with "Local Items" keychain in my environment.
```
KEYCHAIN_NAME=azuki
```

# Usage
## Encrypt
azuki [-e] \<raw file\>

## Decrypt
azuki [-d] \<ZIP file\>
