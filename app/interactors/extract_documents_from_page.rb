class ExtractDocumentsFromPage
  include Troupe
  include Bellbro::Ringable
  include Chronograph

  expects  :page, :adapters

  permits  :browser_session

  benchmark_with :parse_times

  provides(:documents) do
    adapters.map do |adapter|
      page.doc.xpath(adapter.xpath).map do |node|
        benchmark(adapter.name) do
          extract_document_from_node(node: node, adapter: adapter)
        end
      end
    end.flatten
  end

  def extract_document_from_node(node:, adapter:)
    ExtractDocumentFromNode.call(
      node:            node,
      adapter:         adapter,
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
