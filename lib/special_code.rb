class SpecialCode
  def self.get_code(type,txt)
    SPEC_CODET[type][txt]
  end

  def self.get_text(type,code)
    SPEC_CODEC[type][code]
  end

  def self.get_codes_and_text(type)
    SPEC_CODET[type]
  end
end
