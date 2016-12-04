# MongoSessionStore [![Build Status](https://travis-ci.org/brianhempel/mongo_session_store.png?branch=master)](https://travis-ci.org/brianhempel/mongo_session_store) [![Gem Version](https://badge.fury.io/rb/mongo_session_store-rails4.svg)](http://badge.fury.io/rb/mongo_session_store-rails4)

This gem is for Rails 3 and 4. For Rails 5 and later, see [mongoid/mongo_session_store](https://github.com/mongoid/mongo_session_store).

## Description

MongoSessionStore is a collection of Rails-compatible session stores for MongoMapper and Mongoid, but also included is a generic Mongo store that works with any (or no!) Mongo ODM.

MongoSessionStore is tested [on Travis CI](https://travis-ci.org/brianhempel/mongo_session_store) against Ruby 1.9.3, 2.0.0, 2.1.5, 2.2.0, and JRuby with Rails 3.1 through 4.2.

Mongoid users: This gem is compatible with both Mongoid 3 and 4.

If this gem doesn't work for you, you might next try [mongo_sessions](https://github.com/biilmann/mongo_sessions).

See the [Changelog](#changelog) if you need support for an older version of Ruby, Rails, or Mongoid.

## Usage

MongoSessionStore is compatible with Rails 3.1 through 4.2.

In your Gemfile:

```ruby
gem "mongo_mapper"
# or gem "mongoid"
# or gem "mongo"
gem "mongo_session_store-rails4"
# or gem "mongo_session_store-rails3"
```

In the session_store initializer (config/initializers/session_store.rb):

```ruby
# MongoMapper
MyApp::Application.config.session_store :mongo_mapper_store

# Mongoid
MyApp::Application.config.session_store :mongoid_store

# anything else
MyApp::Application.config.session_store :mongo_store
MongoStore::Session.database = Mongo::Client.new(["127.0.0.1:27017"], database: "my_app_development")
```

By default, the sessions will be stored in the "sessions" collection in MongoDB.  If you want to use a different collection, you can set that in the initializer:

```ruby
MongoSessionStore.collection_name = "client_sessions"
```

And if for some reason you want to query your sessions:

```ruby
# MongoMapper
MongoMapperStore::Session.where(:updated_at.gt => 2.days.ago)

# Mongoid
MongoidStore::Session.where(:updated_at.gt => 2.days.ago)

# Plain old Mongo
MongoStore::Session.where("updated_at" => { "$gt" => 2.days.ago })
```

## Changelog

6.0.0 supports the Mongo Ruby Driver 2.0 for the generic MongoStore. The other stores are unchanged. Tests added for Rails 4.2. Tests against MongoDB 3.0.1 on Travis CI.

5.1.0 generates a new session ID when a session is not found. Previously, when a session ID is provided in the request but the session was not found (because for example, it was removed from Mongo by a sweeper job) a new session with the provided ID would be created. This would cause a write error if two simultaneous requests both create a session with the same ID and both try to insert a new document with that ID.

5.0.1 suppresses a warning from Mongoid 4 when setting the _id field type to String.

5.0.0 introduces Rails 4.0 and 4.1 support and Mongoid 4 support alongside the existing Rails 3.1, 3.2, and Mongoid 3 support. Ruby 1.8.7 support is dropped. The database is no longer set automatically for the MongoStore when MongoMapper or Mongoid is present. You have to set the database manually whenever you choose to use the vanilla MongoStore.

The last version to support Ruby 1.8.7 is [version 4.1.1](https://rubygems.org/gems/mongo_session_store-rails3/versions/4.1.1).

The last version to support Rails 3.0 or Mongoid 2 is [version 3.0.6](https://rubygems.org/gems/mongo_session_store-rails3/versions/3.0.6).

## Development

To run all the tests:

    rake

To run the tests for a specific store (examples):

    rake test_31_mongo
    rake test_32_mongoid
    rake test_40_mongoid
    rake test_41_mongo_mapper

To see a list of all options for running tests, run

    rake -T

## Previous contributors

MongoSessionStore started as a fork of the DataMapper session store, modified to work with MongoMapper and Mongoid.  Much thanks to all the previous contributors:

* Nicolas Mérouze
* Chris Brickley
* Tony Pitale
* Nicola Racco
* Matt Powell
* Ryan Fitzgerald

## License

Copyright (c) 2011-2014 Brian Hempel
Copyright (c) 2010 Nicolas Mérouze
Copyright (c) 2009 Chris Brickley
Copyright (c) 2009 Tony Pitale

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
