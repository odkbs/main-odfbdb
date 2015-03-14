require 'securerandom'
require 'fileutils'
require 'json'
require 'active_support/inflector'
require_relative './kernel.rb'
require_relative './wambda_base/instance.rb'


module Wambda
  def self.load_path path, wambda_path = File.join(File.dirname(__FILE__), 'wambda_base')  # TODO , revision = nil
    puts path
    puts wambda_path
    files = Dir[File.join(wambda_path, '**', '*.rb')]
    files.each do |file|
      puts file
      filename = File.basename(file).chomp('.rb')
      classpath = File.join(File.dirname(file), filename.camelize)
      if File.directory?(classpath)
        # filename is a ruby class requiring ...
        fail "asdf" unless file.start_with?(wambda_path)
        relative_path = file[wambda_path.length + 1 .. -1].chomp('.rb')
        class_required = relative_path.split(File::SEPARATOR)
        class_name = class_required.pop
        if !class_required.empty?
          class_required[-1] = class_required.last.underscore
        end
        i = Instance.new
        i.name = class_name
        i.ruby_code = File.read(file)
        i.ruby_require = [File.join(class_required)]
        i.ruby_file = relative_path + '.rb'
        puts i.name
        puts i.ruby_require.inspect
        puts i.ruby_file
        puts ""
      else
        # TODO check it is in Instance/Method ...
        puts file
        puts filename
        puts classpath
        fail 'TODO'
      end
    end
  end
end
