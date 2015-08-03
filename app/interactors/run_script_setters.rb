require "addressable/uri"

class RunScriptSetters
  include Troupe

  expects :instance, :node, :page, :adapter

  permits :browser_session

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
end
