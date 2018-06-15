require_relative '../clients/gdpr_client'

module Gdproo
  class AccessRequestWorker
    include Sidekiq::Worker

    sidekiq_options queue: :gdpr

    def perform(type, id, report_id, lines)
      GdprClient.instance.update_report(type: type, id: id, report_id: report_id, data: lines, status: :pending)
    end
  end
end
