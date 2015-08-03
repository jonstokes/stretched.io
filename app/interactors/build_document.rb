class BuildDocument
  include Troupe

  expects :adapter, :page, :instance

  provides(:document) do
    Document::Document.new(
      document_adapter: adapter,
      page:             page,
      properties:       instance
    )
  end
end