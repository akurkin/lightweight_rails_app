# This script deploys particular code commit to the specific environment
# and performs rolling upgrade in rancher.
#

require 'yaml'
require 'rancher/api'

require_relative 'setup'

puts "DETERMINED CUSTOM_JIRA_CARD as #{CUSTOM_JIRA_CARD}"
puts "DETERMINED CUSTOM_BRANCH as #{CUSTOM_BRANCH}"
puts "DETERMINED CUSTOM_STACK_NAME as #{CUSTOM_STACK_NAME}"
puts "DETERMINED CUSTOM_SHORT_COMMIT as #{CUSTOM_SHORT_COMMIT}"

exit(0)
Rancher::Api.configure do |config|
  config.url = "http://#{ENV['RANCHER_HOST']}/v1/"
  config.access_key = ENV['RANCHER_ACCESS_KEY']
  config.secret_key = ENV['RANCHER_SECRET_KEY']
end

PRODUCTION_PROJECT_NAME = 'quotes'

project = Rancher::Api::Project.all.to_a.first
all_stacks = project.environments.to_a
production_stack = all_stacks.select { |x| x.name == PRODUCTION_PROJECT_NAME }.first

puts "PRODUCTION ENVIRONMENT ID: #{production_stack.id} - #{production_stack.name}"

services = production_stack.services.to_a
puts "FOUND #{services.size} services"

old_web_service = services.select { |x| x.type == 'service' && x.name =~ /web/ }.last
old_web_name = old_web_service.name

new_web_name = "web#{CUSTOM_SHORT_COMMIT}"

puts "CURRENTLY RUNNING #{old_web_name}"
puts "UPGRADING TO #{new_web_name}"

new_image_tag = "hub.howtocookmicroservices.com:5000/quotes:#{CUSTOM_SHORT_COMMIT}"
`docker tag -f hub.howtocookmicroservices.com:5000/quotes:latest #{new_image_tag}`
`docker push #{new_image_tag}`

prod_yaml = YAML.load_file('docker-compose.production.yml')

web_service = prod_yaml['web']
web_service['image'] = new_image_tag
web_service['labels'] = {
  'io.rancher.scheduler.affinity:host_label' => 'branch=master'
}

prod_yaml[old_web_name] = web_service
prod_yaml[new_web_name] = web_service

prod_yaml.delete('web')

File.open('docker-compose.upgrade.yml', 'w') { |f| f << prod_yaml.to_yaml }

`rancher-compose -p #{PRODUCTION_PROJECT_NAME} -f docker-compose.upgrade.yml upgrade --wait #{old_web_name} #{new_web_name}`

old_web_service.destroy

puts "SERVICE #{old_web_service.name} has been removed #{old_web_service.state}"
