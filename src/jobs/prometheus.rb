require 'net/https'
require 'json'
require 'date'

SCHEDULER.every '15s', :first_in => 0 do |job|
  begin
    now = Time.now.utc

    http = Net::HTTP.new('prometheus', 9090)
    request = Net::HTTP::Get.new('/api/v1/query_range?query=scrape_duration_seconds&start=' +(now - 3 * 3600).strftime("%Y-%m-%dT%H:%M:%S.%LZ") +'&end=' + now.strftime("%Y-%m-%dT%H:%M:%S.%LZ") +'&step=20s')
    response = http.request(request)

    points = []
    JSON.parse(response.body)['data']['result'][0]['values'].each do |node|
      points.push( {:x => node[0], :y => node[1].to_f} )
    end

    send_event('scrape_duration_seconds', points: points)
  rescue => e
    puts "Error: #{e}"
  end
end