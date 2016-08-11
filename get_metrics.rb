#!/bin/ruby
require 'net/http'
require 'json'

MACKEREL_API_LOCATION = 'https://mackerel.io/api/v0'.freeze

class API
  def initialize(api_key)
    @api_key = api_key
  end

  def get_json(url)
    request = Net::HTTP::Get.new(url.path)
    request['X-Api-Key'] = @api_key
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.request(request)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    else
      puts response.value
      exit
    end
  rescue => e
    puts [e.class, e].join("\n")
    exit
  end
end

def organization_url
  URI.parse("#{MACKEREL_API_LOCATION}/org")
end

print 'Api Key: '
api = API.new(STDIN.gets.chomp)

organization = api.get_json(organization_url)
puts "Organization:"
puts "  name: #{organization['name']}"
