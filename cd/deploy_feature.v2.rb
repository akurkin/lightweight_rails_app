# Objectives of this script is to:
# - check if docker host for branch exists (using labels)
# - create docker host via Rancher if it doesn't exist
# - build docker-compose.yml file for services with scheduling policy
#   by label for branch
#

require 'yaml'
require 'rancher/api'

require_relative 'setup'

puts "DETERMINED CUSTOM_JIRA_CARD as #{CUSTOM_JIRA_CARD}"
puts "DETERMINED CUSTOM_BRANCH as #{CUSTOM_BRANCH}"
puts "DETERMINED CUSTOM_STACK_NAME as #{CUSTOM_STACK_NAME}"
puts "DETERMINED CUSTOM_SHORT_COMMIT as #{CUSTOM_SHORT_COMMIT}"

DIGITAL_OCEAN_ACCESS_TOKEN = ENV['DIGITAL_OCEAN_ACCESS_TOKEN']

Rancher::Api.configure do |config|
  config.url = "http://#{ENV['RANCHER_HOST']}/v1/"
  config.access_key = ENV['RANCHER_ACCESS_KEY']
  config.secret_key = ENV['RANCHER_SECRET_KEY']
end

project = Rancher::Api::Project.all.to_a.first
all_machines = project.machines

# 1. check if docker host exists
machine = all_machines.select { |x| x.labels['branch'] == CUSTOM_BRANCH }.first

# 2. docker host doesn't exist, let's create one
unless machine
  machine = project.machines.build
  machine.name = CUSTOM_STACK_NAME
  machine.driver = Rancher::Api::Machine::DIGITAL_OCEAN
  machine.driver_config = Rancher::Api::Machine::DriverConfig.new(
    accessToken: DIGITAL_OCEAN_ACCESS_TOKEN,
    size: '1gb',
    region: 'ams3',
    image: 'ubuntu-14-04-x64'
  )

  machine.labels = {
    jira_card: CUSTOM_JIRA_CARD,
    branch: CUSTOM_BRANCH
  }

  machine.save

  puts "CREATING NEW MACHINE: #{machine.id} - #{machine.name}"
  puts 'Going to wait 240 seconds...'

  # Wait until machine is active, on Digital Ocean claim to be 55 seconds
  Timeout.timeout(240) do
    i = 45
    puts "Waiting #{i} seconds..."
    sleep i

    while machine.transitioning == 'yes'
      puts machine.transitioningMessage

      puts "Waiting #{i} seconds ..."
      sleep i
      machine = Rancher::Api::Machine.find(machine.id)
    end
  end
end

# see if we need to upgrade or deploy stack
#
#

all_stacks = project.environments.to_a
current_stack = all_stacks.select { |x| x.name == CUSTOM_STACK_NAME }.first

new_image_tag = "hub.howtocookmicroservices.com:5000/quotes:#{CUSTOM_JIRA_CARD}.#{CUSTOM_SHORT_COMMIT}"

if current_stack
  # TO IMPLEMENT: perform rolling upgrade on subsequent commits to feature branch
else
  `docker build -t #{new_image_tag} .`
  `docker push #{new_image_tag}`

  new_web_name = "web#{CUSTOM_SHORT_COMMIT}"

  puts "DEPLOYING SERVICE #{new_web_name}"

  prod_yaml = YAML.load_file('docker-compose.production.yml')

  web_service = prod_yaml['web']
  web_service['image'] = new_image_tag
  web_service['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{CUSTOM_JIRA_CARD}"
  }
  prod_yaml[new_web_name] = web_service

  # link new service to load balancer
  prod_yaml['lb']['links'] = [new_web_name]
  prod_yaml['lb']['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{CUSTOM_JIRA_CARD}"
  }

  prod_yaml['db']['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{CUSTOM_JIRA_CARD}"
  }

  prod_yaml.delete('web')
  File.open('docker-compose.feature.yml', 'w') { |f| f << prod_yaml.to_yaml }

  `rancher-compose -p #{CUSTOM_STACK_NAME} -f docker-compose.feature.yml up -d`
end
