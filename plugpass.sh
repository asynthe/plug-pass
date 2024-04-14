#!/usr/bin/env bash

################### CONFIGURATION ###################

# Set PASSWORD_STORE_DIR to current directory
export PASSWORD_STORE_DIR=$(pwd)

# Check if ./.gpg-keys directory exists, if not, create it
if [ ! -d "./.gpg-keys" ]; then
    mkdir -p ./.gpg-keys
fi

# Check if ./.gpg-keys directory exists, if not, create it
if [ ! -d "./.gpg-keys" ]; then
    mkdir -p ./.gpg-keys
fi

# Restarting the gpg-agent and using pinentry-curses
pkill gpg-agent
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
    echo "6. Exit"
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

# 3. Add a key
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

    # Generate GPG key
    if [ "$key_type" == "RSA" ]; then
    gpg --batch --generate-key <<EOF
    Key-Type: RSA
    Key-Length: $key_length
    Subkey-Type: RSA
    Subkey-Length: $key_length
    Name-Real: $name
    Name-Email: $email
    Expire-Date: 2y
EOF
    else

    gpg --batch --generate-key --curve=ed25519 --personal-digest-preferences=sha256 <<EOF
    Key-Type: $key_type
    Name-Real: $name
    Name-Email: $email
    Expire-Date: 2y
EOF
    fi

    # Export the GPG key
    gpg --export-secret-keys --armor $email > ./.gpg-keys/$email.asc

    # Add GPG key to Password Store
    pass init $email
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
        6) exit ;;
        *) echo "Invalid option. Please choose again." ;;
    esac
done

# ---------------------------------

# All in Docker?
# - direnv
# - gpg
# - gpg-agent
# - pinentry-curses

# Menu
# 1. Read a password
#   asd
# 2. Create a password
#   asd

# 3. Add a key
#   find all .gpg-id files from specific directories.
