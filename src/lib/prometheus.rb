require 'net/https'
require 'json'
require 'date'

class Prometheus

  def initialize(options)
    @host=options[:host]
    @port=options[:port]
  end

  def query_range(query, step, start_timestamp=nil, end_timestamp=nil)
    now = Time.now.utc

    begin
      http = Net::HTTP.new(@host, @port)
      request = Net::HTTP::Get.new(
          '/api/v1/query_range?query=' + query +
              '&start=' + rfc3339(start_timestamp.nil? ? (now - 3 * 60 *60) : start_timestamp) +
              '&end=' + rfc3339(end_timestamp.nil? ? now : end_timestamp) +
              '&step=' + step)
      response = JSON.parse(http.request(request).body)

      if response['status'] == 'error'
        raise response['error']
      end

      points = []
      response['data']['result'][0]['values'].each do |node|
        points.push({:x => node[0].ceil, :y => node[1].to_f})
      end

      return points
    rescue => e
      puts "Error: #{e}"
    end
  end

  def rfc3339(timestamp)
    timestamp.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
  end

  private :rfc3339

end
