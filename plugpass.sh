#!/usr/bin/env bash

# All in Docker?
# - direnv
# - gpg
# - gpg-agent
# - pinentry-curses

# - After importing all the keys, check the expiration date
# If expiration date is in around 30 days, show it on the front as a line

set -x

################### CONFIGURATION ###################

# Set PASSWORD_STORE_DIR to current directory
export PASSWORD_STORE_DIR=$(pwd)

# Check if ./.gpg-keys directory exists, if not, create it
if [ ! -d "./.gpg-keys" ]; then
    mkdir -p ./.gpg-keys
fi

# Restarting the gpg-agent and using pinentry-curses
pkill gpg-agent

# Linux
gpg-agent --daemon --pinentry-program /usr/bin/pinentry-curses

# NixOS
#gpg-agent --pinentry-program=/home/ben/.nix-profile/bin/pinentry-curses --daemon

################### MENU ###################

display_menu() {
    echo "Password Store Menu"
    echo "1. Read a password"
    echo "2. Create a password"
    echo "3. Add a key"
    echo "4. Remove a key"
    echo "5. Generate and add GPG key to password-store"
    echo "6. Import all gpg keys to keyring"
    echo "7. Exit"
}

# 1. Read a password
read_password() {
    pass
    read -p "Enter the name of the password to read: " pass_name
    pass show $pass_name
}

# 2. Create a password
read_password() {
    read -p "Enter the name of the password to read: " pass_name
    pass show $pass_name
}

# 3. Add a key to database
add_key() {
    read -p "Enter the name of the password to add key: " pass_name
    read -p "Enter the new key: " key
    pass insert -m $pass_name $key
}

# 4. Remove a key
remove_key() {
    read -p "Enter the name of the password to remove key: " pass_name
    read -p "Enter the key to remove: " key
    pass rm $pass_name/$key
}

# 5. Generate and add GPG key to password-store
generate_and_add_gpg_key() {
    read -p "Enter your email address: " email
    read -p "Enter your full name: " name

     # Prompt for key type
    echo "Choose the key type:"
    echo "1. RSA (2048-bit)"
    echo "2. EC25519"
    read -p "Enter your choice: " key_type_choice

    case $key_type_choice in
	    1)
		    key_type="RSA"
		    key_length="2048"
		    ;;
	    2)
		    key_type="EC25519"
		    key_length=""
		    ;;
	    *)
		    echo "Invalid choice. Defaulting to RSA (2048-bit)."
		    key_type="RSA"
		    key_length="2048"
		    ;;
    esac

     # Prompt for expiration date
    read -p "Enter the expiration date (leave empty for no expiration, format: YYYY-MM-DD): " expire_date

    # Generate GPG key
    if [ "$key_type" == "RSA" ]; then
    gpg --batch --generate-key <<EOF
    Key-Type: RSA
    Key-Length: $key_length
    Subkey-Type: RSA
    Subkey-Length: $key_length
    Name-Real: $name
    Name-Email: $email
    Expire-Date: $expire_date
EOF
    else

    gpg --batch --generate-key --curve=ed25519 --personal-digest-preferences=sha256 <<EOF
    Key-Type: $key_type
    Name-Real: $name
    Name-Email: $email
    Expire-Date: $expire_date
EOF
    fi

    # Export the GPG key
    echo "[+] The public key will be put into ./.gpg-keys"
    echo "[!] The private key will be put into the currect folder,"
    echo "remember to save it!"

    gpg --export --armor $email > ./$email.pub.asc
    gpg --export-secret-keys --armor $email > ./.gpg-keys/$email.sec.asc
    
    # Import the GPG key
    gpg --import ./$email.pub.asc
    gpg --import ./.gpg-keys/$email.sec.asc

    # Set the key to ultimate trust
    echo "trust" | gpg --command-fd 0 --edit-key $email
    echo "5" | gpg --command-fd 0 --edit-key $email
    echo "y" | gpg --command-fd 0 --edit-key $email
    echo "quit" | gpg --command-fd 0 --edit-key $email

    # Add GPG key to Password Store
    echo "Select the folders to grant access to (separated by commas):"
    tree -d -L 1 ./
    read -p "Enter your choice(s): " folder_choices
    
    # Prompt the user to select the folders
    # Loop through selected folders and write fingerprint to corresponding .gpg-id files
    for choice in $(echo $folder_choices | tr ',' ' '); do
        case $choice in
            */)
                folder=$(echo "$choice" | sed 's|/$||') ;;
            *)
                folder="$choice" ;;
        esac
        if [ -n "$folder" ]; then
            fingerprint=$(gpg --fingerprint --with-colons $email | awk -F: '/^fpr:/ {print $10; exit}')
            echo "$fingerprint" > ./$folder/.gpg-id
        fi
    done
}

# 6) Import all gpg keys to keyring
import_all_gpg_keys() {
    # Do you want to import all gpg keys to your keyring? (Y/N)
    read -p "Do you want to import all GPG keys to your keyring? (Y/N): " choice
    case "$choice" in
        [Yy])
            gpg --import ./gpg-keys/*.asc
            echo "Done!"
            sleep 2
            ;;
        *)
            echo "Returning to the main menu..."
            sleep 2
            return
            ;;
    esac
}

# Main script
while true; do
    display_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) read_password ;;
        2) create_password ;;
        3) add_key ;;
        4) remove_key ;;
	5) generate_and_add_gpg_key ;;
	6) import_all_gpg_keys ;;
        7) exit ;;
        *) echo "Invalid option. Please choose again." ;;
    esac
done
