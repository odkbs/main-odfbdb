class Hash
  def to_e; self; end
  def attr_internal_value; self; end
end

class Array
  def to_e; self; end
  def attr_internal_value; self; end
end

class String
  def to_e; self; end
  def attr_internal_value; self; end
end

class Numeric
  def to_e; self; end
  def attr_internal_value; self; end
end

class FalseClass
  def to_e; self; end
  def attr_internal_value; self; end
end

class TrueClass
  def to_e; self; end
  def attr_internal_value; self; end
end

class NilClass
  def to_e; self; end
  def attr_internal_value; self; end
end
