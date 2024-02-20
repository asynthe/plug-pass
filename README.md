# Shared password-store

- [Multiple shared password stores with Git and pass - zwyx.dev](https://zwyx.dev/blog/shared-password-stores)

- Adding a key
- Using this repository as a shared password-store
- Is it posible to create a gpg key without password

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

# GPG
## Exporting a key

Public Key
`$ gpg --output public.pgp --armor --export <name/email>`

Private Key
`$ gpg --output public.pgp --armor --export-secret-key <name/email>`

## Importing a key
_note_: If you import a private key, the public key will be imported too.

`$ gpg --import public.asc`
`$ gpg --import private.asc`

# Shared password-store
For each individual folders, add a `.gpg-id` 

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
