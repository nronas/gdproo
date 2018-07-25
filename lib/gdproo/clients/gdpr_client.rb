class GdprClient
  include Singleton

  PATHS = {
    new_report: "#{ENV['GDPR_PORTAL_HOST']}/reports",
    update_report: "#{ENV['GDPR_PORTAL_HOST']}/reports/{id}",
  }

  def create_report(type:, id:, category:)
    response = connection.post(PATHS[:new_report], report: { id: id, type: type, category: category })

    raise "Response to GDPR server failed with #{response.status} status code" unless response.success?
  end

  def update_report(type:, id:, report_id:, data: [], status:)
    payload = { type: type, data: data, status: status }
    response = connection.put(PATHS[:update_report].gsub('{id}', report_id.to_s), report: payload)

    raise "Response to GDPR server failed with #{response.status} status code" unless response.success?
  end

  def connection
    Faraday.new do |f|
      f.use Faraday::Request::Authorization, 'Token', ENV['GDPR_PORTAL_TOKEN']
      f.request :json
      f.response :mashify
      f.response :json, content_type: /\bjson/
      f.adapter :typhoeus
      f.options.timemout = ENV.fetch('GDPR_CLIENT_TIMEOUT', 5).to_f
      f.options.open_timemout = ENV.fetch('GDPR_CLIENT_OPEN_TIMEOUT', 2).to_f
    end
  end
end
