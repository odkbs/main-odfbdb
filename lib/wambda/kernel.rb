require 'securerandom'
require 'fileutils'
require 'json'
require 'active_support/inflector'


require_relative './utils.rb'


module Wambda
  def self.initialize path  # TODO , revision = nil
    fail "Already initialized" if @@path != nil
    @@path = path
    ['Instance', 'Space', 'Frame', 'InstanceMethod', 'Entity'].each do |wid|
      wobj = get_wambda_id(wid)

    end
  end

  def self.get_wambda_id_from_string id
    if id =~ /^[A-Za-z][A-Za-z0-9_]*$/ && id[-1] != '_' && id !~ /__/ && id.length < 255
      id
    else
      nil
    end
  end

  def self.add obj
    @@commands << ['add_instance', obj]
  end

  def self.remove_instances obj
    @@commands << ['remove_instance', obj.uid]
  end

  def self.commit message
    @@commands.each { |command| perform_command(command) }
    `cd #{data_path} ; git commit -m #{message}`  # TODO return revision
  end


  def self.new_uid
    SecureRandom.uuid
  end

  def self.get_instance uid  # TODO , version = nil
    # TODO implement cache
    paths = `find #{data_path} -type f -name #{uid}_*' -print0`.split("\u0000")
    paths.map do |path|
      _, _, version = path.rpartition('_')
      version = version.split('.')
      version << path
      # TODO apply version... =, >, >=, <, <=, ~>
    end
    # get the max version
    path = paths.sort.last
    JSON.parse(FILE.read(path))
  end
  
  def self.get_wambda id
    obj = @@ids[id]
    return obj if obj != nil
    @@ids[id] = true
    paths = Dir["#{data_path}/**/#{id}/*_*.json"]
    uids = {}
    paths.map do |path|
      uid, _, version = File.basename(path).rpartition('_')
      version = version.split('.')
      version << path
      fail "More than one candidate: #{uid}, #{uids[uid]}" if uids[uid]
      uids[uid] = true
    end
    path = paths.sort.last
    wobj = JSON.parse(FILE.read(path))
    wobjs[:require].each { |wid| get_wambda(wid) }
    # write
    wobjs[:ruby_filename]
    wobjs[:ruby_code]
    wobjs[:ruby_get_object]
    # require
    @@ids[id] = wobj  # load object Kernel.const_get Kernel.method
  end


  def self.add_wambda_base path
    # create Instance
    # create Instance
  end

private
  def self.perform_command command
    command, arg = command
    case command
    when 'remove_instance'
      remove_instances(arg)
    when 'add_instance'
      add_instance(arg)
    else
      fail 'TODO'
    end
  end

  def self.remove_instance uid
    `find #{data_path} -type f -name #{uid}_* -exec git rm -f {} '+'`
  end

  def self.add_instance obj
    filename = get_path(obj)
    mkdir_p(File(filename).dirname)  # TODO only if needed
    File.open(filename, File::WRONLY|File::TRUNC|File::CREAT, 0644) do |file|
      file.write(obj.to_json)
    end
    `git add #{filename}`
  end

  def self.get_filename obj
    "#{obj.uid}_#{obj.version}"
  end

  def self.get_path uid, obj
    File.join([data_path] + obj.instance_path + [get_filename(obj)])
  end

  def self.data_path
    File.join(@@path, 'data')
  end
  def self.wambda_path
    File.join(@@path, 'wambda')
  end
end
