require 'net/https'
require 'json'

SCHEDULER.every '15s', :first_in => 0 do |job|
  begin
    http = Net::HTTP.new('prometheus', 9090)
    request = Net::HTTP::Get.new('/api/v1/query_range?query=scrape_duration_seconds&start=2017-04-13T00:00:00.000Z&end=2017-04-20T00:00:00.000Z&step=20s')
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