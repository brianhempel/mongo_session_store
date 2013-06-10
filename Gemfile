source :rubygems

MONGO_VERS = '1.8.0' unless defined? MONGO_VERS

RAILS_VERS = case ENV['RAILS_VERS']
             when '3.1'
               '~>3.1.0'
             when '3.2'
               '~>3.2.0'
             when nil
               nil
             else
               raise "Invalid RAILS_VERS.  Available versions are 3.1, and 3.2."
             end

gemspec

group :development, :test do
  gem 'rake'
  if !ENV['MONGO_SESSION_STORE_ORM'] || ENV['MONGO_SESSION_STORE_ORM'] == 'mongo_mapper'
    gem 'mongo_mapper', '>= 0.10.1'
  end

  if !ENV['MONGO_SESSION_STORE_ORM'] || ENV['MONGO_SESSION_STORE_ORM'] == 'mongoid'
    gem 'mongoid', '~> 3.0', :platforms => [:ruby_19, :jruby, :ruby_20]
  end

  if !ENV['MONGO_SESSION_STORE_ORM'] || ENV['MONGO_SESSION_STORE_ORM'] == 'mongo'
    gem 'mongo',         MONGO_VERS
  end
  gem 'bson_ext',      MONGO_VERS, :platforms => :ruby

  gem 'system_timer', :platforms => :ruby_18
  gem 'rbx-require-relative', '0.0.5', :platforms => :ruby_18
  gem 'ruby-debug',   :platforms => :ruby_18 unless ENV['TRAVIS']
  gem 'debugger',     :platforms => :ruby_19 unless ENV['TRAVIS']

  if RUBY_PLATFORM == 'java'
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbc-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jruby-openssl'
    gem 'jruby-rack'
  else
    gem 'sqlite3' # for devise User storage
  end
  RAILS_VERS ? gem('rails', RAILS_VERS) : gem('rails')

  gem 'rspec-rails', '2.12.0'
  gem 'devise'
end
