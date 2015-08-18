# Objectives of this script is to:
# - check if docker host for branch exists (using labels)
# - create docker host via Rancher if it doesn't exist
# - build docker-compose.yml file for services with scheduling policy
#   by label for branch
#

require 'yaml'
require 'json'
require 'rest-client'

RANCHER_ACCESS_KEY = ENV['RANCHER_ACCESS_KEY']
RANCHER_SECRET_KEY = ENV['RANCHER_SECRET_KEY']
RANCHER_HOST = ENV['RANCHER_HOST']

RANCHER_BASE_URL = "http://#{RANCHER_ACCESS_KEY}:#{RANCHER_SECRET_KEY}@#{RANCHER_HOST}"

DIGITAL_OCEAN_ACCESS_TOKEN = ENV['DIGITAL_OCEAN_ACCESS_TOKEN']
BRANCH = ENV['CIRCLE_BRANCH']

JIRA_CARD = if BRANCH =~ /feature\/(.*)/
  $1.to_s
else
  ''
end

STACK_NAME = "quotes-#{JIRA_CARD}"

def full_url(path)
  RANCHER_BASE_URL + path
end

body = RestClient.get(full_url('/v1/projects/1a5/hosts'))
all_machines = JSON.parse(body)['data']

# 1. check if docker host exists
machine = all_machines.find { |x| !x['labels'].nil? && x['labels']['branch'] == BRANCH }

# 2. docker host doesn't exist, let's create one
unless machine
  # POST /v1/projects/1a5/machines
  new_machine_path = '/v1/projects/1a5/machines'

  json = {
    'name' => STACK_NAME,
    'digitaloceanConfig' => {
      'accessToken' => DIGITAL_OCEAN_ACCESS_TOKEN,
      'size' => '1gb',
      'region' => 'ams3',
      'image' => 'ubuntu-14-04-x64'
    },
    'labels' => {
      'jira_card' => JIRA_CARD,
      'branch' => BRANCH
    }
  }

  body = RestClient.post(full_url(new_machine_path), json.to_json, content_type: :json, accept: :json)
  machine = JSON.parse(body)
  puts "CREATING NEW MACHINE: #{machine['id']} - #{machine['name']}"
  puts 'Sleeping 45 seconds...'

  # Wait until machine is active, on Digital Ocean claim to be 55 seconds
  Timeout.timeout(240) do
    sleep 45
    data = {}
    i = 45

    while !%w(active error bootstrapping).include? data['state'] do
      sleep 5

      body = RestClient.get(full_url("/v1/projects/1a5/machines/#{machine['id']}"))
      data = JSON.parse(body)

      i += 10
      puts "Waiting #{i} seconds ..."
    end
  end
end

# see if we need to upgrade or deploy stack
#
#

body = RestClient.get(full_url('/v1/projects/1a5/environments/'))
all_stacks = JSON.parse(body)['data']

current_stack = all_stacks.find { |x| x['name'] == STACK_NAME }

new_image_tag = "hub.howtocookmicroservices.com:5000/quotes:#{JIRA_CARD}"

if current_stack
  # TO IMPLEMENT: perform rolling upgrade on subsequent commits to feature branch
else
  `docker build -t #{new_image_tag} .`
  `docker push #{new_image_tag}`

  short_commit = `git rev-parse --short=4 $CIRCLE_SHA1`.chomp
  new_web_name = "web#{short_commit}"

  puts "DEPLOYING SERVICE #{new_web_name}"

  prod_yaml = YAML.load_file('docker-compose.production.yml')

  web_service = prod_yaml['web']
  web_service['image'] = new_image_tag
  web_service['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{JIRA_CARD}"
  }
  prod_yaml[new_web_name] = web_service

  # link new service to load balancer
  prod_yaml['lb']['links'] = [new_web_name]
  prod_yaml['lb']['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{JIRA_CARD}"
  }

  prod_yaml['db']['labels'] = {
    'io.rancher.scheduler.affinity:host_label' => "jira_card=#{JIRA_CARD}"
  }

  prod_yaml.delete('web')
  File.open('docker-compose.feature.yml', 'w') { |f| f << prod_yaml.to_yaml }

  `rancher-compose -p #{STACK_NAME} -f docker-compose.feature.yml up -d`
end
