# Droplr

This is a Ruby wrapper for the Droplr API, aimed at making it easy for developers to do basic tasks related to drops and accounts on behalf of Droplr users.

## Installation

Add this line to your application's Gemfile:

    gem 'droplr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install droplr

## Usage

For more detailed instructions on requesting a key for your application, please see [our support article on the topic](http://support.droplr.com/kb/api-development/introduction). Instructions on using our Ruby gem are below.

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

The following are available actions:

* [Read Account Details](#read-account-details)
* [Edit Account Details](#edit-account-details)
* [List Drops](#list-drops)
* [Read Drop](#read-drop)
* [Shorten Link](#shorten-link)
* [Create Note](#create-note)
* [Upload File](#upload-file)
* [Delete Drop](#delete-drop)

-----

#### Errors

If you get an error from a call, you'll receive a hash that looks like the following:

    {:errorcode    => "DeleteDrop.NoDrop",
     :errordetails => "No such drop"}

Which you can then pass along to your users.

-----

#### The Response Object

A response will come back like such:

    {:object_type => {:object => "representation"},
     :request     => {:status => 200}}

Where the `object_type` could be *account*, *drops*, or *drop*, and `status` will be an HTTP code indicating the response's status.

-----

#### Read Account Details

Example call:

    droplr.read_account_details

Expected information in `response[:account]`:

    {:id                => "user_id",
     :created_at        => 1323892487389,
     :type              => "PRO",
     :subscription_end  => 1355428487313,
     :max_upload_size   => 1073741824,
     :extra_space       => 0,
     :used_space        => 4051627,
     :total_space       => 107374182400,
     :email             => "user_email@example.com",
     :use_domain        => true,
     :domain            => "example.com",
     :use_root_redirect => false,
     :root_redirect     => "http://example.com",
     :drop_privacy      => "PRIVATE",
     :theme             => "LIGHT",
     :drop_count        => 65,
     :referrals         => 3}

Returns an object representing the user in question. The response fields are: id, created_at, type, subscription_end (only present if type is "PRO"), max_upload_size, extra_space, used_space, total_space, email, use_domain, domain (only if use_domain is set), use_root_redirect, root_redirect (only if use_root_redirect is set), drop_privacy, theme, drop_count, and referrals.

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

Expected information in `response[:account]`:

    {:id                => "user_id",
     :created_at        => 1323892487389,
     :type              => "PRO",
     :subscription_end  => 1355428487313,
     :max_upload_size   => 1073741824,
     :extra_space       => 0,
     :used_space        => 4051627,
     :total_space       => 107374182400,
     :email             => "user_email@example.com",
     :use_domain        => true,
     :domain            => "example.com",
     :use_root_redirect => false,
     :root_redirect     => "http://example.com",
     :drop_privacy      => "PRIVATE",
     :theme             => "LIGHT",
     :drop_count        => 65,
     :referrals         => 3}

Returns an object representing the user in question. The response fields are: id, created_at, type, subscription_end (only present if type is "PRO"), max_upload_size, extra_space, used_space, total_space, email, use_domain, domain (only if use_domain is set), use_root_redirect, root_redirect (only if use_root_redirect is set), drop_privacy, theme, drop_count, and referrals.

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
* `type` defaults to "ALL", but could be "LINK", "NOTE", "IMAGE", "AUDIO", "VIDEO", or "FILE".
* `sortby` defaults to "CREATION", but could be "CODE", "CREATION", "TITLE", "SIZE", "ACTIVITY", or "VIEWS"
* `order` defaults to "ASC"
* `order` expects an upcased string: "ASC" or "DESC"

Expected information in `response[:drops]`:

    # this could get hairy, so suffice it to say:
    [{ # read_drop response },
     { # read_drop response },
     { # read_drop response },
     { # read_drop response }]

Returns an array of objects representing the retrieved drops. Returns an object representing the retrieved drop. Each object will contain: code, created_at, type, title, size, privacy, password, obscure_code, shortlink, variant, views, and last_access.

#### Read Drop

Example call:

    droplr.read_drop("xkcd")

Accepts a string that is the short code of a drop to read.

Expected information in `response[:drop]`:

    {:code         => "xkcd",
     :created_at   => 1337689077179,
     :type         => "NOTE",
     :title        => "A Great Drop Title Here",
     :size         => 19,
     :privacy      => "PRIVATE",
     :password     => "2f7gGaCQ",
     :obscure_code => "1BnZtKfssD4KaLyV",
     :shortlink    => "http://d.pr/n/xkcd",
     :variant      => "plain",
     :views        => 0,
     :last_access  => 1337689077179,
     :content      => "The entirety of the note contents"}

Returns an object representing the retrieved drop. Each object will contain: code, created_at, type, title, size, privacy, password, obscure_code, shortlink, variant, views, last_access, and content (a full representation of the note, or a deep-link to an image that will expire in a minute).

#### Shorten Link

Example call:

    droplr.shorten_link("http://example.com")

Accepts a string that is the URL to be shortened.

Expected information in `response[:drop]`:

    {:code        => "xkcd",
     :created_at   => 1337689253816,
     :type        => "LINK",
     :title       => "http://example.com",
     :size        => 18,
     :privacy     => "PRIVATE",
     :password    => "3J4RuxXV",
     :obscure_code => "uZzrulunwsOprz5Z",
     :shortlink   => "http://d.pr/xkcd",
     :used_space   => 4051627,
     :total_space  => 107374182400,
     :content      => ""}

Returns an object representing the retrieved link drop. Each object will contain: code, created_at, type, title, size, privacy, password, obscure_code, shortlink, used_space, total_space, and content.

#### Create Note

Example call:

    droplr.shorten_link("A note that will be uploaded.", {
      :variant => "markdown"
    })

Accepts a string that is the note to be created, an a hash, which may optionally contain a variant of plain, code, markdown, or textile.

Param details:

* `variant` defaults to "plain", but could be "plain", "code", "textile", or "markdown"

Expected information in `response[:drop]`:

    {:code         => "xkcd",
     :created_at   => "1337689077179",
     :type         => "NOTE",
     :title        => "A note that will be uploaded.",
     :size         => "19",
     :privacy      => "PRIVATE",
     :password     => "2f7gGaCQ",
     :obscure_code => "1BnZtKfssD4KaLyV",
     :shortlink    => "http://d.pr/n/xkcd",
     :used_space   => 4051609,
     :total_space  => 107374182400,
     :variant      => "markdown",
     :content      => "A note that will be uploaded."}

Returns an object representing the created note. Each object will contain: code, createdat, type, title, size, privacy, password (only if privacy was set to "PRIVATE"), obscurecode, shortlink, usedspace, totalspace, variant.

#### Upload File

Example call:

    path          = File.expand_path(File.dirname(__FILE__) + '/fixtures/droplr-logo.png')
    content_type  = `file --mime -b #{path}`.gsub(/;.*$/, "").chomp
    file          = File.open(path, "rb")

    droplr.upload_file(file, {
      :content_type => content_type,
      :filename     => "My Awesome File"
    })

Accepts binary data for a file to be created and an options hash.

Param details:

* A `filename` in the options hash is required.
* A `content_type` in the options hash is required and should be the file's MIME type.

Expected information in `response[:drop]`:

    {:code        => "xkcd",
     :created_at   => "1337693881277",
     :type         => "IMAGE",
     :title        => "Filename Here",
     :size         => "4651",
     :privacy      => "PRIVATE",
     :password     => "dKUhRaro",
     :obscure_code => "1bshZ6IFDC7d3QcF",
     :shortlink    => "http://d.pr/i/xkcd",
     :used_space   => "4065713",
     :total_space  => "107374182400",
     :variant      => "image/png",
     :content      => "77+977+977+977+977+9Xu+/vQ=="}

Returns an object representing the created drop. Each object will contain: code, createdat, type, title, size, privacy, password (only if privacy was set to "PRIVATE"), obscurecode, shortlink, usedspace, totalspace, variant.

#### Delete Drop

Example call:

    droplr.delete_drop("xkcd")

Accepts a string that is the code of the drop to be deleted.

Expected information in `response[:request]`:

    {:success => true}

Nothing fancy here, just check for success because there will be no `object_type` hash.