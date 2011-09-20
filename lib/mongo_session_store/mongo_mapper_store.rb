require 'mongo_mapper'
require 'mongo_session_store/mongo_store_base'

module ActionDispatch
  module Session
    class MongoMapperStore < MongoStoreBase

      class Session
        include MongoMapper::Document
        set_collection_name MongoSessionStore.collection_name

        key :_id,  String
        key :data, Binary, :default => Marshal.dump({})

        timestamps!
      end

    end
  end
end

MongoMapperStore = ActionDispatch::Session::MongoMapperStore
