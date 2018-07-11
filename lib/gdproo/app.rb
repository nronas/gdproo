require_relative 'processors/access_request_parent_worker'

module Gdproo
  class App
    def initialize(builder)
      @builder = builder
      enable_mappigs(@builder)
    end

    def enable_mappigs(builder)
      builder.use GdprAuth do |username, password|
        username == ENV['GDPR_CLIENT_USERNAME'] &&
          password == ENV['GDPR_CLIENT_PASSWORD']
      end

      builder.map '/legal_hold_deletion' do
        run LegalHoldDeletion.new
      end

      builder.map '/access_request' do
        run AccessRequest.new
      end
    end

    class GdprAuth < Rack::Auth::Basic
      def call(env)
        request = Rack::Request.new(env)
        case request.path
        when '/legal_hold_deletion', '/access_request'
          super
        else
          @app.call(env)
        end
      end
    end

    class LegalHoldDeletion
      def call(env)
        [202, {}, {}]
      end
    end

    class AccessRequest
      def call(env)
        data = JSON.parse(env['rack.input'].read)
        Gdproo::AccessRequestParentWorker.perform_async(data['id'], data['type'], data['report_id'])
        [202, {}, {}]
      end
    end
  end
end
