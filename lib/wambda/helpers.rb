def e obj = nil
  obj ? obj.to_e : Instance.new
end


class Symbol
  def to_e  ; Wambda::w(self) ; end
end

class Regexp
  def to_e  ; Wambda::w(self.source) ; end
end




module Wambda
  # _integer    instance uid
  # identifier  wambda id
  def self.w id
    # TODO
    sid = id.to_s unless sid.is_a?(String)
    if sid[0] == '_'
      frame_uid(id[1..-1])
    else
      wambda_id(id)
    end
  end
end
