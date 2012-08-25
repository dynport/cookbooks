#!/usr/bin/env ruby
#
class Dna
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def hostname
    @hostname ||= File.basename(path)[/(.*?)\.json$/, 1]
  end

  def online?
    @online ||= `ping -c 1 #{hostname} 2>&1`.include?("1 packets received")
  end
end

Dir.glob(File.expand_path("../../servers/*.json", __FILE__)).each do |path|
  dna = Dna.new(path)
  puts "#{dna.hostname}: #{dna.online?}"
end
