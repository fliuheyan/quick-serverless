#! /usr/bin/env ruby

require_relative "main"

# Discard blank environment settings
%w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN).each do |var|
  ENV.delete(var) if ENV[var] == ""
end

$stdout.sync = true
$stderr.sync = true

Deploy::MainCommand.run
