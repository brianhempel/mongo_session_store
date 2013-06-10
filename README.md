# MongoSessionStore [![Build Status](https://travis-ci.org/brianhempel/mongo_session_store.png?branch=master)](https://travis-ci.org/brianhempel/mongo_session_store)

## Description

MongoSessionStore is a collection of Rails-compatible session stores for MongoMapper and Mongoid, but also included is a generic Mongo store that works with any (or no!) Mongo ODM.

MongoSessionStore is tested [on Travis CI](https://travis-ci.org/brianhempel/mongo_session_store) against Ruby 1.8.7, 1.9.3, and JRuby. As of this writing, it also works on Rubinius in 1.9 mode and on Ruby 2.0.0.

If this gem doesn't work for you, you might next try [mongo_sessions](https://github.com/biilmann/mongo_sessions).

## Usage

MongoSessionStore is compatible with Rails 3.1 and 3.2. (Use [version 3.0.6](https://rubygems.org/gems/mongo_session_store-rails3/versions/3.0.6) if you need Rails 3.0 support.)

In your Gemfile:

```ruby
gem "mongo_mapper"
# or gem "mongoid"
# or gem "mongo"
gem "mongo_session_store-rails3"
```

In the session_store initializer (config/initializers/session_store.rb):

```ruby
# MongoMapper
MyApp::Application.config.session_store :mongo_mapper_store

# Mongoid
MyApp::Application.config.session_store :mongoid_store

# anything else
MyApp::Application.config.session_store :mongo_store
MongoStore::Session.database = Mongo::Connection.new.db('my_app_development')
```

Note: If you choose to use `:mongo_store` you only need to set its database if you aren't using MongoMapper or Mongoid in your project.

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
MongoStore::Session.where('updated_at' => { '$gt' => 2.days.ago })
```

Note that Mongoid 2 is no longer supported. Use [version 3.0.6](https://rubygems.org/gems/mongo_session_store-rails3/versions/3.0.6) if you use Mongoid and cannot upgrade to Mongoid 3.

## Performance

The following is the benchmark run with bson_ext installed.  Without bson_ext, speeds are about 10x slower.  The benchmark saves 2000 sessions (~12kb each) and then finds/reloads each one.

    $ ruby perf/benchmark.rb
    MongoMapperStore...
    3.65ms per session save
    2.25ms per session load
               Total Size: 23648924
             Object count: 2000
      Average object size: 11824.462
              Index sizes: {"_id_"=>172032}
    MongoidStore...
    2.59ms per session save
    1.33ms per session load
               Total Size: 23648924
             Object count: 2000
      Average object size: 11824.462
              Index sizes: {"_id_"=>172032}
    MongoStore...
    1.42ms per session save
    1.11ms per session load
               Total Size: 23648924
             Object count: 2000
      Average object size: 11824.462
              Index sizes: {"_id_"=>204800}

## Development

To run all the tests:

    rake

To switch to the Gemfile.lock for a certain Rails version:

    rake use_rails_31
    rake use_rails_32

To run the tests for a specific store:

    MONGO_SESSION_STORE_ORM=mongo_mapper bundle exec rspec spec
    MONGO_SESSION_STORE_ORM=mongoid bundle exec rspec spec
    MONGO_SESSION_STORE_ORM=mongo bundle exec rspec spec    
    
## Previous contributors

MongoSessionStore started as a fork of the DataMapper session store, modified to work with MongoMapper and Mongoid.  Much thanks to all the previous contributors:

* Nicolas Mérouze
* Chris Brickley
* Tony Pitale
* Nicola Racco
* Matt Powell
* Ryan Fitzgerald

## License

Copyright (c) 2011-2012 Brian Hempel
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
