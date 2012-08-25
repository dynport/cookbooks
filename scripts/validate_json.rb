#!/usr/bin/env ruby
require "json"

errors = 0

Dir.glob(File.expand_path("../../**/*.json", __FILE__)).each do |path|
  begin
    JSON.parse(File.read(path))
  rescue => err
    puts "#{path}: #{err.message.inspect}"
    errors += 1
  end
end

if errors > 0
  abort "%d errors" % [errors]
else
  puts "OK"
end
