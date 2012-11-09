begin
  require 'mongoid'
  require 'mongo_session_store/mongo_store_base'

  module ActionDispatch
    module Session
      class MongoidStore < MongoStoreBase

        class Session
          include Mongoid::Document
          include Mongoid::Timestamps

          if Mongoid::VERSION.to_i > 2
            store_in :collection => MongoSessionStore.collection_name

            field :_id, :type => String

            field :data, :type => Moped::BSON::Binary, :default => Moped::BSON::Binary.new(:generic, Marshal.dump({}))
          else
            self.collection_name = MongoSessionStore.collection_name

            identity :type => String

            field :data, :type => BSON::Binary, :default => BSON::Binary.new(Marshal.dump({}))
          end

          attr_accessible :_id, :data
        end

        private
        def pack(data)
          if Mongoid::VERSION.to_i > 2
            Moped::BSON::Binary.new(:generic, Marshal.dump(data))
          else
            BSON::Binary.new(Marshal.dump(data))
          end
        end
      end
    end
  end

  MongoidStore = ActionDispatch::Session::MongoidStore

rescue LoadError
end
