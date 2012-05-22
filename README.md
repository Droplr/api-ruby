# Droplr

This is a Ruby wrapper for the Droplr API, aimed at making it easy for developers to do basic tasks related to drops and accounts on behalf of Droplr users.

## Installation

Add this line to your application's Gemfile:

    gem 'droplr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install droplr

-----

## Usage

For more detailed documentation on the Droplr API, including instructions on requesting a key for your application, please see [TODO](http://example.com/addlink).

-----

### Initialization

Initialize a Droplr client in the following way:

    droplr = Droplr::Client.new({
      :token           => "droplr_user@example.com",
      :secret          => OpenSSL::Digest::SHA1.hexdigest("user_password"),
      :use_production  => false,
      :app_public_key  => "app_0_publickey",
      :app_private_key => "app_0_privatekey",
      :user_agent      => 'DroplrWebTests/1.0.3'
    })

You'll only need to set `use_production` if your application is currently in its staging period. This property will default to true, but if your app has not been granted production access yet, all calls will fail.

-----

### Actions

#### Read Account Details

Example call:

    droplr.read_account_details

    {"id"              => "user_id",
     "createdat"       => "1323892487389",
     "subscriptionend" => "1355428487313",
     "type"            => "PRO",
     "extraspace"      => "0",
     "usedspace"       => "4051627",
     "email"           => "user_email@example.com",
     "usedomain"       => "false",
     "rootredirect"    => "http://example.com",
     "userootredirect" => "false",
     "dropprivacy"     => "PRIVATE",
     "activedrops"     => "18",
     "dropcount"       => "65",
     "maxuploadsize"   => "1073741824",
     "totalspace"      => "107374182400"}

Expected response:

Returns an object representing the user in question. The response fields are: id, createdat, subscriptionend (only present if type is "PRO"), type, extraspace, usedspace, email, usedomain, domain (only if usedomain is set), rootredirect, userootredirect, dropprivacy, activedrops, dropcount, maxuploadsize, totalspace.

#### Edit Account Details

Example call:

    droplr.edit_account_details({
      :password => "new_password",
      :theme    => "LIGHT"
    })

Accepts a hash that can potentially contain the following fields, and must contain at least one: password, theme, usedomain, domain, userootredirect, rootredirect, dropprivacy. These are the fields that will be updated.

Param details:

* `password` needs to be an alphanumeric string that fits the pattern `[a-zA-Z0-9]{4,32}`
* `theme` is free-form, but typical values are "default", "light", and "dark".
* `theme` defaults to "default" when viewing drops in Droplr's web app. (Pro accounts only.)
* `dropprivacy` should be "PUBLIC" or "PRIVATE". (Pro accounts only.)

Expected response:

    {"id"              => "user_id",
     "createdat"       => "1323892487389",
     "subscriptionend" => "1355428487313",
     "type"            => "PRO",
     "extraspace"      => "0",
     "usedspace"       => "4051627",
     "email"           => "user_email@example.com",
     "usedomain"       => "false",
     "rootredirect"    => "http://example.com",
     "userootredirect" => "false",
     "dropprivacy"     => "PRIVATE",
     "activedrops"     => "18",
     "dropcount"       => "65",
     "maxuploadsize"   => "1073741824",
     "totalspace"      => "107374182400"}

Returns an updated object representing the user in question. The response fields are: id, createdat, subscriptionend, type, extraspace, usedspace, email, usedomain, rootredirect, userootredirect, dropprivacy, activedrops, dropcount, maxuploadsize, totalspace.

#### List Drops

Example call:

    droplr.list_drops({
      :limit    => 4,
      :offset   => 50,
      :order    => "ASC"
    })

Accepts a hash that can potentially contain the following fields, but may contain none: offset, amount, type, sortBy, order, since, until. These are the parameters by which the response will be built.

Param details:

* `since` and `until` expect a timestamp in milliseconds elapsed since UTC
* `offset` defaults to 0
* `amount` defaults to 10
* `type` defaults to ALL # TODO possible options?
* `sortby` defaults to CREATION  # TODO possible options?
* `order` defaults to ASC
* `order` expects an upcased string: "ASC" or "DESC"

Expected response:

    # this could get hairy, so suffice it to say:
    [{ # read_drop response },
     { # read_drop response },
     { # read_drop response },
     { # read_drop response }]

Returns an array of objects representing the retrieved drops. Each object will contain: code, createdat, type, variant, title, views, lastaccess, size, filecreatedat, privacy, password, obscurecode, shortlink.

#### Read Drop

Example call:

    droplr.read_drop("xkcd")

Accepts a string that is the short code of a drop to read.

Expected response:

    {"code"        => "xkcd",
     "createdat"   => "1337689077179",
     "type"        => "NOTE",
     "variant"     => "plain",
     "title"       => "dGVzdGluZyBhIG5vdGUgZHJvcA==",
     "views"       => "0",
     "lastaccess"  => "1337689077179",
     "size"        => "19",
     "privacy"     => "PRIVATE",
     "password"    => "2f7gGaCQ",
     "obscurecode" => "1BnZtKfssD4KaLyV",
     "shortlink"   => "http://d.pr/n/xkcd"}

Returns an object representing the retrieved drop. Each object will contain: code, createdat, type, variant, title, views, lastaccess, size, privacy, password, obscurecode, shortlink.

#### Shorten Link

Example call:

    droplr.shorten_link("http://example.com")

Accepts a string that is the URL to be shortened.

Expected response:

    {"code"        => "xkcd",
     "createdat"   => "1337689253816",
     "type"        => "LINK",
     "title"       => "aHR0cDovL2V4YW1wbGUuY29t",
     "size"        => "18",
     "privacy"     => "PRIVATE",
     "password"    => "3J4RuxXV",
     "obscurecode" => "uZzrulunwsOprz5Z",
     "shortlink"   => "http://d.pr/xkcd",
     "usedspace"   => "4051627",
     "totalspace"  => "107374182400"}

Returns an object representing the retrieved link drop. Each object will contain: code, createdat, type, title, size, privacy, password (only if privacy was set to "PRIVATE"), obscurecode, shortlink, usedspace, totalspace.

#### Create Note

Example call:

    droplr.shorten_link("A note that will be uploaded.", {
      :variant => "markdown"
    })

Accepts a string that is the note to be created, an a hash, which may optionally contain a variant of plain, code, markdown, or textile.

Param details:

* `variant` expects "plain", "code", "textile", or "markdown"
* `variant` default to "plain"

Expected response:

    {"code"        => "xkcd",
     "createdat"   => "1337689077179",
     "type"        => "NOTE",
     "title"       => "dGVzdGluZyBhIG5vdGUgZHJvcA==",
     "size"        => "19",
     "privacy"     => "PRIVATE",
     "password"    => "2f7gGaCQ",
     "obscurecode" => "1BnZtKfssD4KaLyV",
     "shortlink"   => "http://d.pr/n/xkcd",
     "usedspace"   => "4051609",
     "totalspace"  => "107374182400",
     "variant"     => "markdown"}

Returns an object representing the created note. Each object will contain: code, createdat, type, title, size, privacy, password (only if privacy was set to "PRIVATE"), obscurecode, shortlink, usedspace, totalspace, variant.

#### Upload File

Example call (TODO : update this with a real response):

    droplr.upload_file("binary_file_string", {:filename => "My Awesome File"})

Accepts binary data for a file to be created and an options hash.

Param details:

* A filename in the options hash is required.

Expected response (TODO : update this with a real response):

    {"code"        => "xkcd",
     "createdat"   => "1337689077179",
     "type"        => "NOTE",
     "title"       => "dGVzdGluZyBhIG5vdGUgZHJvcA==",
     "size"        => "19",
     "privacy"     => "PRIVATE",
     "password"    => "2f7gGaCQ",
     "obscurecode" => "1BnZtKfssD4KaLyV",
     "shortlink"   => "http://d.pr/n/xkcd",
     "usedspace"   => "4051609",
     "totalspace"  => "107374182400",
     "variant"     => "markdown"}

Returns an object representing the created drop. Each object will contain: code, createdat, type, title, size, privacy, password (only if privacy was set to "PRIVATE"), obscurecode, shortlink, usedspace, totalspace, variant.

#### Delete Drop

Example call:

    droplr.delete_drop("xkcd")

Accepts a string that is the code of the drop to be deleted.

Param details:

* A filename in the options hash is required.

Expected response (TODO : update this with a real response):

    "TODO"

TODO : what does this return?

------