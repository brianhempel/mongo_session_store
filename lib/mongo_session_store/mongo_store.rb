require 'mongo'
require 'mongo_session_store/mongo_store_base'

module ActionDispatch
  module Session
    class MongoStore < MongoStoreBase
      class Session
        attr_accessor :_id, :data, :created_at, :updated_at

        def initialize(options = {})
          @_id        = options[:_id]
          @data       = options[:data] || BSON::Binary.new(Marshal.dump({}), :generic)
          @created_at = options[:created_at]
          @updated_at = options[:updated_at]
        end

        def self.load(options = {})
          %w(_id data created_at updated_at).each do |field|
            options[field.to_sym] = options[field] if options[field]
          end

          new(options)
        end

        def scope
          collection.find(:_id => _id)
        end

        def destroy
          scope.delete_one
        end

        def save
          @created_at ||= Time.now
          @updated_at   = Time.now

          attributes = {
            :data       => BSON::Binary.new(@data, :generic),
            :created_at => @created_at,
            :updated_at => @updated_at
          }

          scope.replace_one(attributes, upsert: true)
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
          else
            raise "MongoStore needs a database, e.g. MongoStore::Session.database = Mongo::Client.new(['127.0.0.1:27017'], database: \"my_app_development\")"
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
