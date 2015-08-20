module UUIDTools
  class UUID
    def self.regexp
      /\A([0-9a-f]{4}-?){7}[0-9a-f]{4}\z/i
    end

    def self.parse_string(str)
      UUIDTools::UUID.parse_hexdigest(Digest::MD5.hexdigest(str))
    end

    def self.validate(str)
      !!str[regexp]
    end
  end
end