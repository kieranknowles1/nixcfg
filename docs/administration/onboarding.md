# User Onboarding

Steps for introducing new users to a server. By the end of the process, users
will be able to log in and have a basic understanding of any services they will
use.

## Account Creation

1. Create a new account entry in `/mnt/extern/data/authelia/users_database.yml`
   with the following format:

```yml
users:
  <user_name>:
    # Set initial password using `authelia crypto hash generate argon2`
    password: <hashed_password>
    displayname: <firstname>
    email: <email>
    groups:
      - human
```

To ensure zero-knowledge of passwords, use a random string as the initial
password and have users perform a password reset. Do not save the temporary
password.

2. Create identities for the user with services they will use. These include:

- [Actual](https://finance.selwonk.uk/user-directory)

3. Instruct the user to log in on [auth.selwonk.uk](https://auth.selwonk.uk) and
   register their device for one-time-passwords. If necessary, provide
   instructions on whitelisting `auth@selwonk.uk` in their spam filter.

4. Introduce users to their new account and the services they will use, giving
   them a tour and basic instructions.

<!--
  // TODO: Guide for Actual. Cover bank imports, categories, and basic budgeting
  // TODO: Guide for Paperless. Cover what to do with tags, correspondents, and categories
-->

## Paperless

- Create a new user account
- Assign to the `users` group for default permissions
- Log in as the new user
- Create an **Inbox** saved view, filtered by the **Inbox** tag and shown on the
  sidebard and dashboard.
