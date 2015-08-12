class ExtractDocumentFromNode
  class BuildDocument
    include Troupe

    expects :page, :instance, :adapter

    provides(:document) do
      Document.new(
        properties: instance,
        page_id:    page.id,
        adapter_id: adapter.id
      )
    end
  end
end
