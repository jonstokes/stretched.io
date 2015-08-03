require "addressable/uri"

class RunScriptSetters
  include Troupe

  expects :instance, :node, :page, :adapter

  permits :browser_session

  provides :document

  def call
    adapter.runners.each do |script_runner|
      script_runner.set_context(
        doc:             node,
        page:            page,
        browser_session: browser_session,
      )
      script_runner.run(instance)
    end
  end

  after do
    # FIXME: Doc should be added to queue here
    context[:document] = Document::Document.new(
      document_adapter: adapter,
      page:             page,
      properties:       instance
    )
  end
end
