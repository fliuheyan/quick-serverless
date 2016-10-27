#!/usr/bin/env ruby
require 'json'
file_name= ARGV[0]
if file_name.nil?
	puts "please give a file"
end

file = File.read(file_name)
data = JSON.parse(file)
array=[]
data.each {| key,value | array.push({"ParameterKey"=>"#{key}", "ParameterValue"=>"#{value}"}) }
File.open("parameters.json","w") {|f| f.write(JSON.pretty_generate(array))}
