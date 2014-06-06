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
          session = find_session(sid)
          unless session
            session, sid = build_session
          end
          env[SESSION_RECORD_KEY] = session
          [sid, unpack(session.data)]
        end

        def set_session(env, sid, session_data, options = {})
          record, id = get_session_model(env, sid)
          record.data = pack(session_data)
          # Rack spec dictates that set_session should return true or false
          # depending on whether or not the session was saved or not.
          # However, ActionPack seems to want a session id instead.
          record.save ? id : false
        end

        def find_session(id)
          id && session_class.where(:_id => id).first
        end

        def build_session
          id = generate_sid
          return [session_class.new(:_id => id), id]
        end

        def get_session_model(env, sid)
          if env[ENV_SESSION_OPTIONS_KEY][:id].nil?
            env[SESSION_RECORD_KEY] = find_session(sid)
          else
            env[SESSION_RECORD_KEY] ||= find_session(sid)
          end

          if !env[SESSION_RECORD_KEY]
            record, sid = build_session
            env[SESSION_RECORD_KEY] = record
          end

          [env[SESSION_RECORD_KEY], sid]
        end

        def destroy_session(env, session_id, options)
          destroy(env)
          generate_sid unless options[:drop]
        end

        def destroy(env)
          if sid = current_session_id(env)
            get_session_model(env, sid).first.destroy
            env[SESSION_RECORD_KEY] = nil
          end
        end

        def pack(data)
          Marshal.dump(data)
        end

        def unpack(packed)
          return nil unless packed
          Marshal.load(StringIO.new(packed.to_s))
        end

    end
  end
end
