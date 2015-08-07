class ExtractDocumentFromNode
  class BuildDocument
    include Troupe

    expects :page, :instance, :reader

    provides(:document) do
      Document::Document.new(
        properties:     instance,
        page:           page,
        session_reader: reader
      )
    end
  end
end
