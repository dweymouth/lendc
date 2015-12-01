# lendc
A command-line Lending Club client for Unix systems written in OCaml.

##dependencies
- Yojson
- libcurl (C library)

##building
Run make!

##usage
You need to create a JSON config file at /home/yourname/.config/lendc/lendc.conf that looks like:

    {
        "api-key" : "your-api-key"
        "account-id" : (your account id as int)
    }

Currently, lendc supports only three operations:

- **account** - get basic info about your account
- **notes** - get information about notes you currently own
- **loans** - get a listing of the most recent loans posted to the platform
