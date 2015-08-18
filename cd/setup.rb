branch = ENV['CIRCLE_BRANCH']
jira_card = if branch =~ /feature\/(.*)/
  $1.to_s
else
  ''
end

stack_name = "quotes-#{jira_card}"
short_commit = `git rev-parse --short=4 $CIRCLE_SHA1`.chomp

puts "export CUSTOM_JIRA_CARD=#{jira_card}"
puts "export CUSTOM_BRANCH=#{branch}"
puts "export CUSTOM_STACK_NAME=#{stack_name}"
puts "export CUSTOM_SHORT_COMMIT=#{short_commit}"
