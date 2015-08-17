require 'yaml'
require 'json'
require 'rest-client'

prod_yaml = YAML.load_file('docker-compose.production.yml')

RANCHER_ACCESS_KEY = ENV['RANCHER_ACCESS_KEY']
RANCHER_SECRET_KEY = ENV['RANCHER_SECRET_KEY']
RANCHER_HOST = ENV['RANCHER_HOST']

RANCHER_BASE_URL = "http://#{RANCHER_ACCESS_KEY}:#{RANCHER_SECRET_KEY}@#{RANCHER_HOST}"

PRODUCTION_PROJECT_NAME = 'quotes'

def full_url(path)
  RANCHER_BASE_URL + path
end

body = RestClient.get(full_url('/v1/projects/1a5/environments'))
production_environment_id = JSON.parse(body)['data'].find { |x| x['name'] == PRODUCTION_PROJECT_NAME }['id']

puts "PRODUCTION ENVIRONMENT ID: #{production_environment_id}"

body = RestClient.get(full_url('/v1/projects/1a5/services'))
data = JSON.parse(body)['data']

old_web = data.select { |x| x['type'] == 'service' && x['environmentId'] == production_environment_id && x['name'] =~ /web/ }.last
old_web_name = old_web['name']

short_commit = `git rev-parse --short=4 $CIRCLE_SHA1`.chomp
new_web_name = "web#{short_commit}"

puts "CURRENTLY RUNNING SERVICE IN PRODUCTION: #{old_web_name}"
puts "UPGRADING TO #{new_web_name}"

web_service = prod_yaml['web']
prod_yaml[old_web_name] = web_service
prod_yaml[new_web_name] = web_service

File.open('docker-compose.upgrade.yml', 'w') { |f| f << prod_yaml.to_yaml }

`rancher-compose -p #{PRODUCTION_PROJECT_NAME} -f docker-compose.upgrade.yml upgrade --wait #{old_web_name} #{new_web_name}`

old_web_id = old_web['id']

body = RestClient.post(full_url("/v1/projects/1a5/services/#{old_web_id}/?action=remove"), {}.to_json, content_type: :json, accept: :json)
data = JSON.load(body)

puts "SERVICE #{data['name']} has been removed #{data['state']}"
