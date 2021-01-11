# funding-frontend

## Running locally on macOS

### Install Homebrew

Check to see if [Homebrew](https://brew.sh) is installed by running `which brew` in a terminal. If already 
installed you'll get output similar to `/usr/local/bin/brew`, otherwise the command will return `brew not found`.

If Homebrew is already installed, update it by running `brew update`. 

If Homebrew is not already installed, run 
`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"` to install it.

### Install rbenv

Run `brew install rbenv` to install the latest version of [rbenv](https://github.com/rbenv/rbenv).

Run `rbenv init`, which will run some commands to allow `rbenv` to work with `zsh`, like updating the path.

Add `eval "$(rbenv init -)"` to your `~/.zshrc` profile.

### Install PostgreSQL

Run `brew install postgres` to install the latest version of [PostgreSQL](https://www.postgresql.org).

### Install the recommended version of Ruby

We specify a recommended version of Ruby in the [`.ruby-version`](.ruby-version) file in funding-frontend. 
To install this recommended version of Ruby, use rbenv by running `rbenv install x.y.z` inside the application 
directory (where `x.y.z` is replaced with the version number specified in [`.ruby-version`](.ruby-version)).


You may need to run `rbenv global x.y.z` to switch your terminal to use the new version.

### Install the PostgreSQL app

Download and install [Postgres.app](https://postgresapp.com).

Run the Postgres app.

### Configure the necessary environment variables

Create an empty `.env` file in your application directory by running `touch .env` in a terminal.

The necessary environment variables in order to run the application are stored in the team's shared
1Password vault. If you don't have access to the shared 1Password vault, contact @stuartmccoll or @ptrelease.

With access to the vault, copy the contents of `funding-frontend.env` into your own `.env` file.

### Install the PostgreSQL Gem

Install the PostgreSQL Gem, telling it the path of PostgreSQL. If PostgreSQL is installed in a default 
location, the command will look like:

```bash
gem install pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config
```

### Install Bundler

Run `gem install bundler` to install [Bundler](https://bundler.io).

### Install Yarn

Run `brew install yarn` to install [Yarn]((https://yarnpkg.com/lang/en/docs/install/#mac-stable)).

### Install necessary application dependencies

Run `bundle install` to install the Ruby dependencies necessary for the application to run. These are 
specified in the application's `Gemfile`.

Run `yarn install` to install the Yarn dependencies necessary for the application to run. These are
specified in the application's `package.json` and `yarn.lock` files.

### Initialise the database

Run `bundle exec rails db:setup` in your terminal.  If the database needs creating, run
`psql` then `create database funding_frontend_development;`.

Run `bundle exec rails db:seed` in your terminal. This will have the effect of populating
relevant database tables with the necessary rows to run the application.

### Running the funding-frontend application

Run `bundle exec rails server` (or `bundle exec rails s` for a shorter command) in your terminal. 
The application will now be running locally and can be accessed by navigating to 
`https://localhost:3000` in your browser.

---

## Running the automated test suite

### RSpec

Server-side code is tested using [RSpec](https://rspec.info).

To run the RSpec test suite, run `bundle exec rspec` in your terminal.

### Jest

Client-side code is tested using [Jest](https://jestjs.io).

To run the Jest test suite, run `yarn jest` in your terminal.

---

## Caching

Addresses are cached after searching by postcode so that they can be referred to later in the user journey. 
By default, Ruby-on-Rails in development mode runs with caching disabled. In order to see caching work in 
development, run `bundle exec rails dev:cache` in your terminal.

---

## Toggling feature flags

Some elements of functionality are sat behind feature flags, which have been implemented using 
[Flipper](https://github.com/jnunemaker/flipper).

To toggle functionality, a Flipper needs to exist. Flipper rows exist within the `flipper_features` and 
`flipper_gates` tables on the database. The `flipper_gates` are populated with a database migration. 
The `flipper_features` are populated at app runtime, provided rows exist in `flipper.rb`.

Update a `flipper_gates` row by running a SQL statement such as (after running 
`psql funding_frontend_development` in your terminal to connect to the database):

```postgresql
UPDATE flipper_gates SET value = true WHERE feature_key = '<key_name>';   
```
