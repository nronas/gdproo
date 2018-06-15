module Gdproo
  module Callbacks
    class AccessRequest
      def on_complete(status, options)
        type = options['type']
        id = options['id']
        report_id = options['report_id']

        if status.failures != 0
          GdprClient.instance.update_report(type: type, id: id, report_id: report_id, status: :failure)
        else
          GdprClient.instance.update_report(type: type, id: id, report_id: report_id, status: :success)
        end
      end
    end
  end
end
