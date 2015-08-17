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

old_web = data.find{|x| x['type'] == 'service' && x['environmentId'] == production_environment_id && x['name'] =~ /web/ }
old_web_name = old_web['name']

new_web_name = "web#{ENV['CIRCLE_SHA1']}"

puts "CURRENTLY RUNNING SERVICE IN PRODUCTION: #{old_web_name}"
puts "UPGRADING TO #{new_web_name}"

web_service = prod_yaml['web']
prod_yaml[old_web_name] = web_service
prod_yaml[new_web_name] = web_service

File.open('docker-compose.upgrade.yml', 'w') { |f| f << prod_yaml.to_yaml }

`rancher-compose -p #{PRODUCTION_PROJECT_NAME} -f docker-compose.upgrade.yml upgrade #{old_web_name} #{new_web_name}`
