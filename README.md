# Shared password-store
- Adding a key
- Using this repository as a shared password-store

Put my own public key

Useful variables
GNUPG_HOME -> Location of gpg key. (default `~/.gpg`)
PASSWORD_STORE_DIR -> Location of password store. (default `~/.pass`)

## Import the keys to your keyring
You will have to import the public-keys which will be inside `.public-keys`.
`$ gpg --import plug-pass/.public-keys/*.asc`

## Encrypting password-store for another user
[How to re-encrpt .password-store using new gpg key - StackExchange](https://superuser.com/questions/1238892/how-to-re-encrypt-password-store-using-new-gpg-key)

password-store default location: `~/.pass`, edit with `$ export PASSWORD_STORE_DIR=<path>`
Then use `$ pass init <gpg-id>`

# Fixing from here to below.
# --------------------------------------------------------------------------

## Quick setup / How to use

1. Clone the github repository.
`export PASSWORD_STORE_DIR=<path/to/store>`

2. You will have to import the keys to your gpg keyring.
`gpg --import ~/.password-store-pro/.public-keys/*.asc`

3. Set key

## Importing a key to your gpg keyring

Adding a key to the gpg keyring

Set key trust level, so you can encrypt new passwords
`$ gpg --edit-key <email>`
`gpg> trust`
`Your decision? 5`
`y`
`gpg> save`

## Importing a key

???
Import private and public key
`$ gpg --import private.pgp`
`$ gpg --import public.pgp`


## Password store folders

- [Multiple shared password stores with Git and pass - zwyx.dev](https://zwyx.dev/blog/shared-password-stores)

For each individual folders, add a `.gpg-id` 


# gpg keys
## Creating a key

Create a key
``
_note_: create key in a different directory.
`$ gpg --gen-key --homedir ~/plugpass/keys/nick`

Public Key
`$ gpg --output public.pgp --armor --export <name/email>`

Private Key
`$ gpg --output public.pgp --armor --export-secret-key <name/email>`

## Adding a new user to shared password-store

Add the user key to the `.public-keys` directory.
`$ gpg --import .public-keys/*.asc`

Now that it's imported, get the UID with
`$ gpg --list-keys`

Edit the key, add trust
`gpg --edit-key "Nick <nick@plug.org>"`
`gpg> trust`
`Your decision? 5`
`gpg> quit`

## Adding a user to a shared password-store folder

This

