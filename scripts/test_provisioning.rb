#!/usr/bin/env ruby
require "json"
require "optparse"

class VBoxManager
  def self.id_from_vagrant_file
    JSON.parse(File.read(".vagrant"))["active"]["default"]
  end

  def self.from_vagrant_file
    self.new(id_from_vagrant_file)
  end

  def initialize(id)
    @id = id
  end

  def poweroff!
    info "powering off #{id}"
    if running?
      system "VBoxManage controlvm #{id} poweroff"
      sleep 1
    end
  end

  def running?
    `VBoxManage list runningvms`.include?(id)
  end

  def snapshots
    @snapshots ||= Hash[`VBoxManage snapshot #{id} list`.scan(/Name: (.*?) \(UUID: (.*?)\)/)]
  end

  def restore_snapshot(name)
    poweroff! if running?
    if uuid = snapshots.fetch(name)
      system "VBoxManage snapshot #{id} restore #{uuid}"
    end
  end

  def up
    system "vagrant up"
  end
  
  require "pathname"
  TMP_PATH = Pathname.new(File.expand_path("../../tmp", __FILE__))
  TMP_DNA_PATH = TMP_PATH.join("dna.json")

  def provision_run_list(run_list, apt_update)
    require "fileutils"
    require "json"
    FileUtils.mkdir_p(TMP_PATH)
    File.open(TMP_DNA_PATH, "w") { |f| f.puts({ "run_list" => run_list }.to_json) }
    provision("./tmp/dna.json", apt_update)
  end

  def provision(template_path, apt_update = true)
    cmds = []
    cmds << "sudo apt-get update" if apt_update
    cmds << "sudo /vagrant/provision.sh /vagrant/#{template_path}"
    system %(vagrant ssh -c "#{cmds.join(" ; ")}")
  end

  private

  attr_reader :id

  def info(message)
    puts "INFO: #{message}"
  end
end

attributes = { apt_update: true, did_run: false, action: nil }

opts = OptionParser.new do |o|
  o.on "--reset", "Reset machine to initial snapshot before provisioning" do
    attributes[:reset] = true
  end

  o.on "--poweroff", "Poweroff the vagrant server" do
    attributes[:action] = :poweroff
  end

  o.on("--without-update", "Do not run apt-get update before provisioning") do
    attributes[:apt_update] = false
  end

  o.on "--role ROLE", "Provision using the given role" do |role|
    attributes[:action] = :provision_run_list
    attributes[:run_list] = "role[#{role}]"
  end

  o.on "--recipe RECIPE", "Provision using the given recipe"  do |recipe|
    attributes[:action] = :provision_run_list
    attributes[:run_list] = recipe
  end

  o.on "--dna PATH", "Provision using the dna found under relative (!!!) path (e.g. ./servers/<name_of_server>.json)" do |path|
    attributes[:action] = :provision_path
    attributes[:path] = path
  end
end

opts.parse(ARGV)

abort opts.to_s unless attributes[:action] || attributes[:reset]

MANAGER = VBoxManager.from_vagrant_file

if attributes[:reset]
  MANAGER.restore_snapshot("initial")
  MANAGER.up
end

case attributes.fetch(:action)
when :provision_run_list
  MANAGER.provision_run_list(attributes.fetch(:run_list), attributes.fetch(:apt_update))
when :provision_path
  MANAGER.provision(attributes.fetch(:path), attributes.fetch(:apt_update))
when :poweroff
  MANAGER.poweroff!
end
