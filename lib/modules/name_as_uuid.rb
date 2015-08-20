module NameAsUUID
  def self.included(base)
    base.class_eval do
      extend ClassMethods

      attribute :name, String, mapping: { index: 'not_analyzed' }
      validates :name, presence: true
    end
  end

  def name=(str)
    self.id = str.present? ? UUIDTools::UUID.parse_string(str).to_s : nil
    super(str)
  end

  module ClassMethods
    def find_by_name(name)
      return unless name.present?
      self.find(UUIDTools::UUID.parse_string(name).to_s)
    end
  end
end