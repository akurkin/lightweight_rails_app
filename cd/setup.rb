branch = ENV['CIRCLE_BRANCH']
jira_card = if branch =~ /feature\/(.*)/
              $1.to_s
            else
              ''
            end

stack_name = if jira_card != ''
               "quotes-#{jira_card}"
             else
               'quotes'
             end

circle_commit = ENV['CIRCLE_SHA1']
short_commit = `git rev-parse --short=4 #{circle_commit}`.chomp

puts "export CUSTOM_JIRA_CARD=#{jira_card}"
puts "export CUSTOM_BRANCH=#{branch}"
puts "export CUSTOM_STACK_NAME=#{stack_name}"
puts "export CUSTOM_SHORT_COMMIT=#{short_commit}"
