require 'mongoid'
require 'mongo_session_store/mongo_store_base'

module ActionDispatch
  module Session
    class MongoidStore < MongoStoreBase

      class Session
        include Mongoid::Document
        include Mongoid::Timestamps
        self.collection_name = MongoSessionStore.collection_name

        identity :type => String

        field :data, :type => BSON::Binary, :default => BSON::Binary.new(Marshal.dump({}))
      end

      private
      def pack(data)
        BSON::Binary.new(Marshal.dump(data))
      end

    end
  end
end

MongoidStore = ActionDispatch::Session::MongoidStore
