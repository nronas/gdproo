require_relative 'processors/access_request_parent_worker'

module Gdproo
  class App
    def initialize(builder)
      @builder = builder
      enable_mappigs(@builder)
    end

    def enable_mappigs(builder)
      builder.map '/legal_hold_deletion' do
        run LegalHoldDeletion.new
      end

      builder.map '/access_request' do
        run AccessRequest.new
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
