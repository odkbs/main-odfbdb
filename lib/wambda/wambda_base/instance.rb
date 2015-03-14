class Instance
  def self.frame
    Frame
  end
  def self.superframe
    self.class == Instance ? nil : superclass
  end
  def self.frame_ancestors
    superclasses = [self.class]
    while superclasses.last != Instance
      superclasses << superclasses.last.superclass
    end
    superclasses
  end
  def frame
    self.class
  end


  def initialize src = nil
    # repository runtime helpers
    @new = @updated = true

    if src == nil
      src = {
        uid:        nil,
        version:    [0,0,0],
        name:       nil,
        accessors:  {},
        #internal_methods:    {},
        #internal_mixins:     {},
        #extended [[method|mixin, uid]
      }
    end

    # index fields
    @uid = src[:uid]
    @version = src[:major], src[:minor], src[:teeny]
    @name = src[:name]

    # @accessors[field] = value s.t. value.to_e? == value  TODO
    @accessors = src[:accessors]
    # @methods[method] = value s.t. value.is_a? Wambda::Method
    #@methods = src[:methods]
    # @methods[method] = value s.t. value.is_a? Wambda::Mixin
    #@mixins = src[:mixins]
  end


  def uid; @uid; end
  def version; @version.join('.'); end
  def name; @name; end
  def name= name; @name = name; end
  def major; @version[0]; end
  def minor; @version[1]; end
  def teeny; @version[2]; end

  def inspect
    char = 'M' if updated?
    char = 'A' if new?
    "<#{char}#{uid ? uid : 'nil'}_#{version} #{frame}> #{@accessors}"
  end


  def new_major!; @version[0] += 1; end
  def new_minor!; @version[1] += 1; end


  def new?
    @new
  end

  def updated?
    @updated
  end

  def valid?
    name != nil && accessors_instances.all { |i| i.valid? }
  end

  def valid!
    raise "invalid instance" unless valid?
  end

  def clone
    # TODO improve dup/clone
    cloned = super
    cloned.reset_uid!
  end

  def dup
    clone
  end

  def save! recursive = false
    if @updated
      valid!
      new_teeny
      assign_uid!(recursive: true)
      @accessors.map { |k,e| e.save!(recursive: recursive) } if recursive
      Wambda::add(internal_representation)
      @updated = @new = false
    end
  end


  def method_missing symbol, *args, &block
    s = symbol.to_s

    # TODO __type

    # *__call
=begin
    method_id = nil
    module_id = nil
    if s.start_with? '_m_'
      method_id = method_symbol_call(s[3 .. -1])
    elsif s.start_with? '_x_'
      module_id, method_id = s[3 .. -1].partition('__')
      method_id = method_symbol_call(method_id)
    else
      method_id = method_symbol_call(s)
      method_id = nil unless method_id && @methods[method_id]
    end

    if method_id
      @updated = true if method_id[-1] == '!'
      if module_id != nil
        @mixins[module_id][method_id].call(args, &block)
      else
        @methods[method_id].call(args, &block)
      end
    end
=end

    # *__set
    wid = accessor_symbol_setter(s)
    if wid
      if args.size != 1
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
      end
      @updated = true
      return @accessors[wid] = args.first
    end

    # *__get
    wid = accessor_symbol_getter(s)
    if wid && args.empty?
      #if !args.empty?
      #  raise ArgumentError, "wrong number of arguments (#{args.size} for 0)"
      #end
      return @accessors[wid]
    end

    super
  end

  def respond_to? symbol, included_all = false
    # TODO
    super
  end



  def to_e; self; end

  def instance_path
    frame_ancestors << name
  end




protected
  def new_teeny!; @version[2] += 1; end

  def internal_value
    {name: name, uid: uid, version: version, path: instance_path}
  end

  def attr_internal_value
    obj = internal_value
    obj['_rt'] = true
    obj
  end

  def internal_representation
    i = internal_value
    i[:frame]     = frame
    i[:accessors] = Hash[@accessors.map { |k,e| [k, e.attr_internal_value] }]
    #i[:methods]   = Hash[@methods.map   { |k,e| [k, e.attr_internal_value] }]
    #i[:mixins]    = Hash[@mixins.map    { |k,e| [k, e.attr_internal_value] }]
    i
  end

  def reset_uid!
    @uid = nil
  end

  def assign_uid! recursive = true
    if recursive
      accessors_instances.each { |k,e| e.assign_uid!(recursive: recursive) }
    end
    @uid = Wambda::new_uid unless @uid
  end



private
  def accessors_instances
    @accessors.select { |attr| attr.is_a? Instance }
  end

=begin
  def method_symbol_call string
    if string.end_with?('__call!')
      wid = Wambda::get_wambda_id_from_string(string.chomp('__call!')) + '!'
    elsif string.end_with?('__call?')
      wid = Wambda::get_wambda_id_from_string(string.chomp('__call?')) + '?'
    else
      wid = Wambda::get_wambda_id_from_string(string.chomps('', '__call'))
    end
    @methods.key?(wid) ? wid : nil
  end
    # TODO check id exists and is a mehtod...
    # TODO change frame to anon frame
    # TODO add methods _or_ mixin and alias..
  def extend method, id
  end
  def add_method method, id
  end
=end

  def accessor_symbol_getter string
    Wambda::get_wambda_id_from_string(string.chomps('', '__get'))
  end

  def accessor_symbol_setter string
    Wambda::get_wambda_id_from_string(string.chomps('=', '__set'))
  end
end
