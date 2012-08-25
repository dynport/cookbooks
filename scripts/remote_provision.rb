#!/usr/bin/env ruby
require "json"
require "optparse"

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

def all_pushed?
  system "git fetch"
  `git log origin/master..HEAD`.to_s.strip.length == 0
end

def error(message)
  abort "ERROR: #{message}"
end

error "you need to push all pending changes first" unless ENV["DIRTY"] || all_pushed?

def validate_host_config!(hostname)
  path = "servers/#{hostname}.json"
  error "no config for #{hostname} found at #{path}" if !`git ls-files servers`.include?(path)
  begin
    JSON.parse(File.read(File.expand_path("../../#{path}", __FILE__)))
  rescue JSON::ParserError => err
    error "json at #{path} not valid: #{err.message}"
  end
end

attributes = { hosts: [], simulate: false }

opts = OptionParser.new do |o|
  o.on("--hosts HOSTS", Array, "Hosts to provision") do |hosts|
    attributes[:hosts] = hosts
  end

  o.on("--pattern PATTERN", "Pattern to use to select servers") do |pattern|
    attributes[:pattern] = pattern
  end

  o.on("--simulate", "Only simulate the run") do |pattern|
    attributes[:simulate] = true
  end
end

opts.parse(ARGV)

ROOT = File.expand_path("../../servers", __FILE__)

paths = attributes.fetch(:hosts).map { |host| "#{ROOT}/#{host}.json" }

not_found_paths = paths.select { |path| !File.exists?(path) }

abort "no dna found for #{not_found_paths.map { |path| File.basename(path) }.join(", ")}" if not_found_paths.any?

if pattern = attributes[:pattern]
  paths += Dir.glob("#{ROOT}/*.json").select { |path| File.basename(path).include?(pattern) }
end

paths.uniq!

dnas = paths.map { |path| Dna.new(path) }

not_pingable = dnas.select { |dna| !dna.online? }

error "#{not_pingable.map { |dna| dna.hostname }.join(", ")} not pingable" if not_pingable.any?

hosts = dnas.map { |dna| dna.hostname }

if hosts.any?
  puts "provisioning #{hosts.count}: #{hosts.join(" ")}"
  exit if attributes[:simulate]
  cmds = [
    %(mkdir -p /root/.ssh),
    %(which curl > /dev/null || apt-get -y install curl),
    %(which git > /dev/null || apt-get -y install git-core),
    %(test -e /root/.ssh/config || echo \\"Host github.com\n  StrictHostKeyChecking no\n\\" >> /root/.ssh/config),
  ]
  if hosts.count == 1
    hostname = hosts.first
    cmds << %(HOSTNAME=\\`cat /etc/hostname\\`)
    cmds << %(test $HOSTNAME == "#{hostname}" || (echo 'updating hostname'; echo '#{hostname}' > /etc/hostname && hostname -F /etc/hostname))
  end
  cmds += [
    "mkdir -p /opt",
    "test -e /opt/chef || git clone --recursive git@github.com:dynport/wimdu_cookbooks.git /opt/chef",
    "/opt/chef/update.sh && /opt/chef/provision.sh && /opt/chef/log_provisioning.sh",
  ]
  ENV["PDSH_SSH_ARGS"] = "-o StrictHostKeyChecking=no -S none -2 -A -x -l%u %h"
  require "fileutils"
  log_path = File.expand_path("../../log/provisioning.%s.log" % Time.now.strftime("%Y%m%dT%H%M%S"), __FILE__)
  FileUtils.mkdir_p(File.dirname(log_path))
  error "please install pdsh first (brew install pdsh)" if `which pdsh`.strip.length == 0

  run_cmd = if hosts.count > 1
    %(pdsh -l root -w #{hosts.join(",")} "#{cmds.join("\n")}" | tee #{log_path})
  else
    %(ssh -S none -A -l root #{hosts.join(",")} "#{cmds.join("\n")}" | tee #{log_path})
  end
  exec run_cmd
else
  puts opts
end
