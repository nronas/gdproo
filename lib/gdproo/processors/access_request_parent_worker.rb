require_relative '../auditer'
require_relative '../callbacks/access_request'
require_relative '../clients/gdpr_client'
require_relative 'access_request_worker'

module Gdproo
  class AccessRequestParentWorker
    include Sidekiq::Worker

    sidekiq_options queue: :gdpr

    def perform(id, type, report_id)
      # Invoce auditer
      batch = Sidekiq::Batch.new
      batch.description = "Processing GDPR subject access request"
      batch.on(:complete, Callbacks::AccessRequest, id: id, type: type, report_id: report_id)

      lines = Gdproo::Auditer.new(type).audit(id: id)

      batch.jobs do
        lines.each_slice(ENV.fetch('GDPR_RESOURCE_SLICE', 100).to_i) do |slice|
          AccessRequestWorker.perform_async(type, id, report_id, slice)
        end
      end
    rescue => e
      puts e.backtrace
    end
  end
end
