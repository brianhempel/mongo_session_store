require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class MongoStoreBase < AbstractStore

      SESSION_RECORD_KEY = 'rack.session.record'.freeze
      begin
        ENV_SESSION_OPTIONS_KEY = Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY
      rescue NameError
        # Rack 1.2.x has access to the ENV_SESSION_OPTIONS_KEY
      end

      def self.session_class
        self::Session
      end

      private
        def session_class
          self.class.session_class
        end

        def generate_sid
          # 20 random bytes in url-safe base64
          SecureRandom.base64(20).gsub('=','').gsub('+','-').gsub('/','_')
        end

        def get_session(env, sid)
          sid, record = find_or_initialize_session(sid)
          env[SESSION_RECORD_KEY] = record
          [sid, unpack(record.data)]
        end

        def set_session(env, sid, session_data, options = {})
          id, record = get_session_record(env, sid)
          record.data = pack(session_data)

          # Custom code that runs (if defined) before the session is saved
          record.before_save_session(env, sid, session_data, options) if record.respond_to?(:before_save_session)

          # Rack spec dictates that set_session should return true or false
          # depending on whether or not the session was saved or not.
          # However, ActionPack seems to want a session id instead.
          record.save ? id : false
        end

        def find_or_initialize_session(id)
          session = (id && session_class.where(:_id => id).first) || session_class.new(:_id => generate_sid)
          [session._id, session]
        end

        def get_session_record(env, sid)
          if env[ENV_SESSION_OPTIONS_KEY][:id].nil? || !env[SESSION_RECORD_KEY]
            sid, env[SESSION_RECORD_KEY] = find_or_initialize_session(sid)
          end

          [sid, env[SESSION_RECORD_KEY]]
        end

        def destroy_session(env, session_id, options)
          destroy(env)
          generate_sid unless options[:drop]
        end

        def destroy(env)
          if sid = current_session_id(env)
            _, record = get_session_record(env, sid)
            record.destroy
            env[SESSION_RECORD_KEY] = nil
          end
        end

        def pack(data)
          Marshal.dump(data)
        end

        def unpack(packed)
          return nil unless packed
          data = packed.respond_to?(:data) ? packed.data : packed.to_s
          Marshal.load(StringIO.new(data))
        end

    end
  end
end
