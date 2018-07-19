require_relative '../deleter'
require_relative '../clients/gdpr_client'

module Gdproo
  class LegalHoldWorker
    include Sidekiq::Worker

    sidekiq_options queue: :gdpr

    def perform(id, type, report_id, id_field)
      Gdproo::Deleter.new(type).delete(id: id, id_field: id_field)

      GdprClient.instance.update_report(type: type, id: id, report_id: report_id, status: :success)
    end
  end
end
