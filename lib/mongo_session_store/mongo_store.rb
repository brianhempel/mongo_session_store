begin
  require 'mongo'
  require 'mongo_session_store/mongo_store_base'

  module ActionDispatch
    module Session
      class MongoStore < MongoStoreBase
        class Session
          attr_accessor :_id, :data, :created_at, :updated_at
          
          def initialize(options = {})
            @_id        = options[:_id]
            @data       = options[:data] || BSON::Binary.new(Marshal.dump({}))
            @created_at = options[:created_at]
            @updated_at = options[:updated_at]
          end
          
          def self.load(options = {})
            options[:data] = options["data"] if options["data"]
            new(options)
          end
          
          def destroy
            collection.remove :_id => _id
          end
          
          def save
            @created_at ||= Time.now
            @updated_at   = Time.now
            
            collection.save(
              :_id        => @_id,
              :data       => BSON::Binary.new(@data),
              :created_at => @created_at,
              :updated_at => @updated_at
            )
          end
          
          def data=(stuff)
            @data = stuff.to_s
          end
          
          def self.where(query = {})
            collection.find(query).map { |doc| load(doc) }
          end
          
          def self.last
            where.last
          end
          
          def self.database
            if @database
              @database
            elsif defined?(MongoMapper)
              MongoMapper.database
            elsif defined?(Mongoid)
              Mongoid.database
            else
              raise "MongoStore needs a database, e.g. MongoStore::Session.database = Mongo::Connection.new.db('my_app_development')"
            end
          end
          
          def self.database=(database)
            @database = database
          end
          
          def self.collection
            @collection ||= database[MongoSessionStore.collection_name]
          end
          
          def self.reset_collection
            @collection = nil
          end
          
          def collection
            self.class.collection
          end
        end
      end
    end
  end

  MongoStore = ActionDispatch::Session::MongoStore

rescue LoadError
end
