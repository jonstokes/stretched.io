module Activisms

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      index_name INDEX_NAME
    end
  end

  def save!
    save
  end

  module ClassMethods
    def belongs_to(attr, opts={})
      attr     = attr.to_s
      klass    = opts[:class_name].try(:constantize) || attr.classify.constantize
      id_field = "#{attr}_id"

      attribute id_field.to_sym, String, mapping: { index: 'not_analyzed' }

      define_method attr do
        next unless attr_id = self.send(id_field)
        instance_variable_get("@#{attr}") || instance_variable_set("@#{attr}", klass.find(attr_id))
      end

      return unless opts[:by] == :name

      attribute "#{attr}_name".to_sym, String, mapping: { index: 'not_analyzed' }

      define_method "#{attr}_name=" do |str|
        val = str.present? ? UUIDTools::UUID.parse_string(str).to_s : nil
        self.send("#{id_field}=", val)
        super(str)
      end
    end

    def belongs_to_many(attr, opts={})
      attr = attr.to_s
      klass = opts[:class_name].try(:constantize) || attr.singularize.classify.constantize
      id_field = "#{attr.singularize}_names"

      attribute id_field.to_sym, String, mapping: { index: 'not_analyzed' }, default: []

      define_method attr do
        return [] unless self.send(id_field).present?
        self.send(id_field).map do |oname|
          klass.find_by_name(oname) || raise("#{self.name} #{id}: #{klass.name} #{oname} does not exist!")
        end
      end
    end

    def has_many(attr, opts={})
      attr = attr.to_s
      klass = opts[:class_name].try(:constantize) || attr.singularize.classify.constantize
      id_field = "#{self.name.downcase}_id"

      define_method attr do
        klass.find_by(id_field => self.id)
      end

      define_method "each_#{attr.singularize}" do |&block|
        klass.find_each(query: { match: { id_field => self.id } }) do |obj|
          block.call(obj)
        end
      end

      define_method "destroy_#{attr}" do
        # FIXME: Batch delete
        self.send("each_#{attr.singularize}") do |obj|
          obj.destroy
        end
      end

      after_destroy("destroy_#{attr}".to_sym) if opts[:dependent] == :destroy
    end

    def find_by(opts)
      self.search(query: { match: opts }).to_a
    end
  end
end
