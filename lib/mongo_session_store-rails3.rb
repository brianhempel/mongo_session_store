require 'securerandom'

$:.unshift File.dirname(__FILE__)

module MongoSessionStore
  autoload :VERSION, 'mongo_session_store/version'

  def self.collection_name=(name)
    @collection_name = name
    
    if defined?(MongoStore::Session)
      MongoStore::Session.reset_collection
    end

    if defined?(MongoMapperStore::Session)
      MongoMapperStore::Session.set_collection_name(name)
    end

    if defined?(MongoidStore::Session)

      if Mongoid::VERSION.to_i > 2
        MongoidStore::Session.store_in :collection => MongoSessionStore.collection_name
      else
        MongoidStore::Session.store_in(name)
      end
    end

    @collection_name
  end

  def self.collection_name
    @collection_name 
  end
  
  # default collection name for all the stores
  self.collection_name = "sessions"
end

require 'mongo_session_store/mongo_mapper_store'
require 'mongo_session_store/mongoid_store'
require 'mongo_session_store/mongo_store'
