#!/usr/bin/env ruby
require 'clamp'
require 'stackup'
require 'aws-sdk'

class MainCommand < Clamp::Command
  option ["-n", "--name"], "NAME", "cloudformation stack name",
         :name => :name,
         :default => "my-stack"

  def initialize(invocation_path, context = {})
    super
    yaml = YAML.load_file(File.expand_path("env/production.yml", File.dirname(__FILE__)))
    @region = yaml[:region]
    @bucket = yaml[:bucket]
    @function = yaml[:function]
    @file = yaml[:file]
    @path = yaml[:folder] + "/" + @file
    client = Aws::STS::Client.new(region: @region)
    response = client.assume_role({
                                    role_arn: "arn:aws:iam::#{yaml[:id]}:role/#{yaml[:role]}",
                                    role_session_name: "lambda"
                                  }).credentials
    @credentials = Aws::Credentials.new(
      response.access_key_id,
      response.secret_access_key,
      response.session_token
    )
  end

  def cloud_formation_client
    Aws::CloudFormation::Client.new(region: @region, credentials: @credentials)
  end

  def s3_client
    Aws::S3::Client.new(
      region: @region,
      credentials: @credentials
    )
  end

  def lambda_client
    Aws::Lambda::Client.new(
      region: @region,
      credentials: @credentials
    )
  end

  def file_context path
    File.open(File.expand_path(path, File.dirname(__FILE__)), 'rb').read
  end

  subcommand ["create"], "creat cloud formation" do
    option ["-t", "--template"], "TEMPLATE", "cloudformation template",
           :template => :template,
           :default => 'cloudformation.json'

    option "--timeout_in_minutes", "TIMEOUT_IN_MINUTES", "timeout in minutes",
           :timeout_in_minutes => :timeout_in_minutes,
           :default => 3

    def execute
      create_or_update_stack
    end

    def create_or_update_stack
      Stackup(cloud_formation_client).stack(name).create_or_update(
        :tags => [],
        :template_body => file_context(template),
        :parameters => [],
        :timeout_in_minutes => timeout_in_minutes
      )
    end
  end

  subcommand ["ls", "list"], "list all stacks" do
    def execute
      Stackup(cloud_formation_client).stack_names.each do |name|
        puts name
      end
    end
  end

  #refactor zip file
  subcommand ["pg", "package"], "package file" do
    def execute
      `cd $(dirname 0)/.. && zip -q -r lambda-function.zip app.js app index.html node_modules models`
      puts "package complete" if $? == 0
    end
  end

  subcommand ["upload"], "upload file file" do
    def execute
      s3_client.put_object(bucket: @bucket, key: @path, body: file_context(@file))
      puts "upload complete"
    end
  end

  subcommand ["update"], "upload file" do
    def execute
      lambda_client.update_function_code({
                                           function_name: @function,
                                           publish: true,
                                           s3_bucket: @bucket,
                                           s3_key: @path
                                         })
      puts "update complete"
    end
  end

  subcommand ["delete"], "delete cloudformation" do
    def execute
      Stackup(cloud_formation_client).stack(name).delete
    end
  end
end

MainCommand.run