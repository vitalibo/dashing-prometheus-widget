require '/lib/prometheus.rb'

prometheus = Prometheus.new(
    {
        :host => 'prometheus',
        :port => 9090
    })

SCHEDULER.every '20s', :first_in => 0 do |job|
  points = prometheus.query_range(
      'scrape_duration_seconds',
      '20s')

  send_event('scrape_duration_seconds', points: points)
end