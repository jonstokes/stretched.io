class ValidateResults
  include Interactor

  expects :instance, :adapter

  def call
    instance.select! do |attribute_name, value|
      adapter.validate(attribute_name, value)
    end
  end
end
