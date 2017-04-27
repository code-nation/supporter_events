# Supporter Events Tool

## App features

1. Event Sync - Empower supporting organisations to clone their events into your central NationBuilder calendar. Those organisations simply connect their nation to this app and the sync process runs daily. You can control which events are cloned - the app only captures events with the specified `EVENT_PAGE_TAG`.

2. Event Importer - This tool allows you to bulk upload spreadsheets of events to your NationBuilder calendar. For example, you could import all election day voting booths and have your supporters RSVP to attend their nearest booth.

3. Event endpoint - Allow your supporters to create their own events without having to activate an account and set a password. You can use a custom event form like [this Stop Adani example](http://www.stopadani.com/create_event) and empower your supporters to lead their own actions.

* All events created via those three methods are created in the `PRIMARY_NATION` (see the relevant environment variables listed below)

## Accessing the demo

There are two ways to access a valid account in the demo version of the [Supporter Events app](http://supporterevents.com).

### Use a demo account

* You can log in as an admin with the following credentials:
    > admin@example.com
    > unhackable

* You can log in as a non-admin user with the following credentials:
    > user@example.com
    > unhackable

### Create your own account

Simply enter your own email address on the [Request Access page](https://supporterevents.herokuapp.com/users/request_access). Once you are approved by an existing admin user you will receive a notification email with a temporary password to create your own account.

## Useful tools for developers

In general, developers may find this app useful when working with a number of key features from the NationBuilder API. For example:

* The API Authentication process (allowing users to connect their nation to the tool)
* NationBuilder API pagination (see it in action - uses the latest version available)
* Accessing resources through OAuth
* Working with the [Sites API](http://nationbuilder.com/sites_api), the [Calendars API](http://nationbuilder.com/calendars_api), the [Events API](http://nationbuilder.com/events_api) and the [People API](http://nationbuilder.com/people_api).
* Converting spreadsheet data to valid API calls through the import process
* Storing log information and error messages regarding imports
* Allowing users to connect multiple nations

## Accessing the NationBuilder developer API

* This tool requires you to create a NationBuilder app in the "Developer" section of your nation's control panel. You are also required to generate a test API token for your primary nation (where all events will be created). Both of those tasks requires access to the NationBuidler developer API.
* Please contact NationBuilder support (help@nationbuilder.com) if you are unable to access either of the following two links (substituting "YOUR_NATION_SLUG" for its correct value):
    * https://YOUR_NATION_SLUG.nationbuilder.com/admin/apps/new
    * https://YOUR_NATION_SLUG.nationbuilder.com/admin/oauth/test_tokens

## NationBuilder app configuration

* Go to https://YOUR_NATION_SLUG.nationbuilder.com/admin/apps/new
    * If you can't view that page, then contact NationBuilder support (help@nationbuilder.com) to secure developer access to the NationBuilder API
* Give the "OAuth callback URL" field the value: `http://localhost:3000/oauth2/callback` when testing locally.
    * Update that value to `https://whateveryourdomainis.com/oauth2/callback` when you're ready to push your app live in production.
* Copy your "OAuth client ID" and "OAuth client secret" - and use them to configure the `OAUTH_CLIENT_ID` and `OAUTH_CLIENT_SECRET` environment variables
* Make sure to use localhost:3000 (not 127.0.0.1:3000) when authenticating with NationBuilder in development, otherwise the redirection won't work

## Types of users and levels of access

* There are two levels of access within this application: Admins and Users.

* Approved users can:
    * Connect a nation to the app and manually trigger the event sync process for their nation (the automatic sync only runs daily by default)
    * Disconnect their nation from the app
    * View which other nations are connected to the app (though they can only take actions on nations that they themselves have connected to the tool)
    * Import events and review the log messages of previously imported files
    * Update their own user profile

* Admins can:
    * Do everything that a normal user can do
    * Invite new users to the app and approve new users who request access
    * View all users and admins of the app
    * Promote users to full admin status from normal user status
    * Take all actions for any nation that has been added to the app:
        * Manually trigger the event sync process for that nation
        * Disconnect that nation from the app
    * Receive notifications when new users request access, or when new events are created by supporters (or opt-out of those notifications if they wish)

## User account creation

* New user accounts can be created directly by existing admin users.

* New user accounts can also be created when someone requests access to the app via the Request Access page (e.g. [here](https://supporterevents.herokuapp.com/users/request_access)) and is subsequently approved by an existing admin. When that admin processes the approval the new user receives a notification email with a temporary password to create their account.

## Email notifications

* The app handles a range of transactional emails:
    * Admins receive a notification email when potential new users request access to the app
    * New users receive a notification email when they are granted access to the app by an admin
    * New users receive a notification email when they are invited to the app by an admin
    * Supporters receive a thank you autoresponder when they create their own event
    * Admins receive a notification email 
    * The emails listed in the `TECH_SUPPORT_EMAIL` environment variable receive a notification with any error messages caused by an invalid submission to the create_event endpoint (if a supporter tries to create an event with invalid data)

* Admin users can choose to opt-out of email notifications. This will prevent them from receiving any notifications from the app other than account emails (e.g. password reset emails). You can see the notifications opt-out screen here: https://supporterevents.herokuapp.com/users/admins.

* In the [Supporter Events demo](http://supporterevents.com/), the admin notification emails will include links to a sandbox nation (codenationdev) that you won't be able to access, but you'll be able to see how those notifications work.

## List of environment variables

### NationBuilder

* OAUTH_CLIENT_ID: _(the value from your NationBuilder app - see "NationBuilder app configuration")_
* OAUTH_CLIENT_SECRET: _(the value from your NationBuilder app - see "NationBuilder app configuration")_
* OAUTH_REDIRECT_PATH: "/oauth2/callback"

### Primary Nation

* PRIMARY_NATION_SITE_SLUG: "some_site_slug" _use the [API explorer](http://apiexplorer.nationbuilder.com/) to find your site slug if you do not know it already_
* PRIMARY_NATION_SLUG: "some_nation_slug"
* PRIMARY_NATION_API_TOKEN: _generate a test token here:_ [https://YOUR_NATION_SLUG.nationbuilder.com/admin/oauth/test_tokens](https://YOUR_NATION_SLUG.nationbuilder.com/admin/oauth/test_tokens)
* PRIMARY_NATION_CALENDAR_ID: a valid calendar ID, e.g. "10" _(use the [API explorer](http://apiexplorer.nationbuilder.com/) to find the relevant calendar ID if you do not know it already)_
* PRIMARY_NATION_SITE_ID: "6" _use the [API explorer](http://apiexplorer.nationbuilder.com/) to find the relevant site ID if you do not know it already (it is also visible in the control panel URL within the website section)_

### NationBuilder Events

* EVENT_PAGE_TAG: "some_tag_slug" (this is the tag that will determine which events are cloned from connected nations)
* EVENT_PAGE_DELETION_TAG: "stop_adani_delete" (this is the tag that will determine which events are deleted from the central calendar after previously being cloned from a connected nation)
* DEFAULT_EVENT_DURATION: "60" (time in minutes)
* VALID_EVENT_PAGE_STATUSES: "published" (a comma-separated list - when finding events in the connected nations, the sync process will only clone those with one of the statuses listed in this environment variable)

### SendGrid (used for notifications and account emails)

* SENDGRID_SERVER: "smtp.sendgrid.net"
* SENDGRID_PORT: "587"
* SENDGRID_DOMAIN: "domain"
* SENDGRID_USERNAME: "username"
* SENDGRID_PASSWORD: "password"

### Pre-defined values

* APP_NAME: "Your Application's name" (e.g. "Supporter Events")
* TECH_SUPPORT_EMAIL: a comma-separated list (e.g. "admin@example.com, foobar@example.com"). When you run `rails db:migrate` an admin account is created for each of the email addresses stored in this environment variable. The temporary password for those new admin accounts is "unhackable".
* EVENT_CREATED_AUTORESPONDER_SUBJECT: The subject line of the autoresponder sent to supporters after they create an event through the website form (e.g. the custom event form in [this Stop Adani example](http://www.stopadani.com/create_event))
* EVENT_CREATED_ADMIN_NOTIFICATION_SUBJECT: The subject line of the notification email sent to all admins when an event is created by a supporter
* ADMIN_INVITATION_SUBJECT: The subject line of the invitation email sent to new admins when their account is created by an existing administrator.
* ADMIN_APPROVAL_SUBJECT: The subject line of the email sent to all admin users when a new user requests access to the tool.
* APPROVED_ACCESS_SUBJECT: The subject line sent to new users after their request to join has been successful.
* APP_DOMAIN: e.g. "supporterevents.herokuapp.com"
* MAILER_SENDER: "info@example.com"
* DEFAULT_TIME_ZONE: "Australia/Brisbane"
* CREATE_EVENT_ENDPOINT_TAGS: "Event, User submitted" _(the tags added to events created by supporters through a website form)_
* IMPORT_EVENT_TAGS: "Event, Imported" _(the tags added to events created through the import process)_
* SYNC_EVENT_TAGS: "Event, Synced" _(the tags added to events created through the sync process with connected nations)_

### Other Optional Variables

* NEW_EVENT_WEBHOOK_URL: An optional variable. You can set a URL to receive event data every time a new supporter event is created. This can be useful when utilising an external service like Zapier's "catch hook" trigger. This allows you to use the new event data in a separate app (e.g. to create a notification in Slack)

## Getting started

### Clone the app to your local system

`git clone https://github.com/code-nation/supporter_events.git`

### Add the environment variables

See the list above. Please note that this app is configured to use the [Figaro gem](https://github.com/laserlemon/figaro) to handle your environment variables (there are a bunch of them!). You can refer to the Figaro documentation for assistance.

### Setup the database

This app is configured to use PostgreSQL. Make sure to add the environment variables above before setting up the database, particularly given your initial admin user accounts are created from the `TECH_SUPPORT_EMAIL` variable (which takes a comma-separated list of emails) when you run the `db:migrate` command:

* `rails db:create`
* `rails db:migrate`

### Take the app for a test drive

* Connect a nation to the tool and trial the event sync process
* Use the event import tool. You can test the app with your own spreadsheet, or use [this example spreadsheet](https://docs.google.com/spreadsheets/d/18n7L8cf7_voYQhfYguyL0so-Ecy_DJiBviyMXE_dJ7g/edit?usp=sharing)
* Create a front-end form to send data to your new create_event endpoint. You can now build a form where supporter can create their own events, like in this [Stop Adani example](http://www.stopadani.com/create_event). You should push your app to staging or production before you test this feature, or use a service like [ngrok](https://ngrok.com/) if you wish to test this create_event endpoint in development.

### Other notes

* Comments have been added where useful to explain the function of certain methods. This is particularly true for `app/helpers/sync_helper.rb`, `app/helpers/events_helper.rb` and `app/helpers/endpoints_helper.rb`.

## Rake tasks

Use the following commands to test/run the core rake tasks:

* `sync:all` syncs everything for all nations
* `sync:nation[nation_slug]` syncs everything for a given nation slug
* `sync:run[nation_slug_,action_name_]` performs a given action for a given nation slug. Possible actions are sites, pages, sync and delete
    * `sites` syncs all nation sites
    * `pages` syncs all event pages for all the synced sites
    * `sync` syncs all pending event pages with the primary nation
    * `delete` deletes all pending deletion event pages with the primary nation

## Future revisions

* Extend the logs tool to show more detailed error data. We could also update the import tool so it works throught the full spreadsheet even if some rows have errors (currently the import process will stop at the first row where an error is encountered)

* Provide a detailed code example of a frontend event form for supporters to create their own events (like the [Stop Adani example](http://www.stopadani.com/create_event))

* Update the docs so developers new to Rails can successfully run a version of this app locally.

## Who are we?

Code Nation is a five-star rated creative agency for progressive advocates and organisations. We specialise in using NationBuilder to create unique and engaging campaign websites that drive supporters to take action for your cause. And we also create excellent apps like this to turbo-charge the great work you do.

Have any questions? Get in touch with our team via our website: www.codenation.com
