class ExtractDocumentFromNode
  class RunJsonSetters
    include Troupe

    expects :node, :page, :reader

    permits :browser_session

    provides(:instance) { {} }

    provides :runner do
      Script.runner
    end

    before do
      runner.set_context(
        doc:             node,
        page:            page,
        browser_session: browser_session,
      )
    end

    def call
      reader.document_adapter.property_queries.each do |attribute_name, setters|
        setters.detect do |setter|
          if setter.is_a?(Hash)
            method = setter.reject {|k,v| k == "filters"}.first.first
            args = setter[method]
            result = args.nil? ? runner.send(method) : runner.send(method, args)
          else
            result = runner.send(setter)
          end
          result = runner.filters(result, setter["filters"]) if setter["filters"]
          next unless result = clean_up(result)
          instance[attribute_name] = result
        end
      end
    end

    def clean_up(result)
      return result unless result.is_a?(String)
      return unless result = ActionView::Base.full_sanitizer.sanitize(result, tags: [])
      result = HTMLEntities.new.decode(result)
      result = result.strip.squeeze(" ") rescue nil
      result.present? ? result : nil
    end
  end
end
