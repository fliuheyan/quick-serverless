require 'yaml'
class AssumeRole

  #TODO
  #using shush to decrypt id

  def initialize
    @yaml=YAML.load_file("env/#{ENV['ENVIRONMENT']}.yml")
  end

  def get_credentials
    client = Aws::STS::Client.new(region: @yaml[:region])
    response = client.assume_role({
       role_arn: "arn:aws:iam::#{@yaml[:id]}:role/#{@yaml[:role]}",
       role_session_name: "lambda"
    })
    response.credentials
  end
  Aws.config.update({region:@region,
                    credentials: get_credentials})
end