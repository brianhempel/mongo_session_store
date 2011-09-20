require 'securerandom'

$:.unshift File.dirname(__FILE__)

module MongoSessionStore
  def self.collection_name=(name)
    @collection_name = name
    
    if defined?(MongoStore::Session)
      MongoStore::Session.reset_collection
    end

    if defined?(MongoMapperStore::Session)
      MongoMapperStore::Session.set_collection_name(name)
    end

    if defined?(MongoidStore::Session)
      MongoidStore::Session.store_in(name)
    end
  end

  def self.collection_name
    @collection_name 
  end
  
  # default collection name for all the stores
  self.collection_name = "sessions"
end

autoload :MongoMapperStore,'mongo_session_store/mongo_mapper_store'
autoload :MongoidStore, 'mongo_session_store/mongoid_store'
autoload :MongoStore, 'mongo_session_store/mongo_store'
