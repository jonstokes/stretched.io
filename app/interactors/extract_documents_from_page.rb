class ExtractDocumentsFromPage
  include Troupe
  include Bellbro::Ringable

  expects  :page, :ssn

  permits  :browser_session

  provides(:documents) do
    ssn.session_readers.map do |reader|
      if page.try(:is_valid?)
        page.doc.xpath(reader.document_adapter.xpath).map do |node|
          extract_document_from_node(node: node, reader: reader)
        end
      else
        Document::Document.new(session_reader: reader, page: page, properties: {})
      end
    end.flatten
  end

  def extract_document_from_node(node:, reader:)
    ExtractDocumentFromNode.call(
      node:            node,
      reader:          reader,
      page:            page,
      browser_session: browser_session
    ).document
  #rescue Exception => e
  #  unless defined?(Sidekiq::Shutdown) && e.is_a?(Sidekiq::Shutdown)
  #    Airbrake.notify(e)
  #    Document::Document.new(session_reader:reader, error: format_error(e))
  #  end
  end

  def format_error(e)
    error = "#{e.message} #{e.inspect}\n"
    return error unless e.backtrace && e.backtrace[1..10]
    e.backtrace[1..10].each do |line|
      error << "#{line}\n"
    end
    error
  end
end
