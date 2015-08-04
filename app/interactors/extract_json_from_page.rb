require "addressable/uri"

class ExtractJsonFromPage
  include Interactor
  include Shout

  attr_accessor :instance

  def user;    context.user;    end
  def adapter; context.adapter; end

  def call
    context.json_objects = context.page.doc.xpath(adapter.xpath).map do |node|
      instance = {}
      instance = run_json_setters(instance, node)
      instance = run_ruby_setters(instance, node)
      instance.select! do |attribute, value|
        adapter.validate(attribute, value)
      end
      instance
    end
  rescue Nokogiri::XML::XPath::SyntaxError => err
    gong "Adapter #{context.adapter_name} from session #{context.stretched_session.inspect} for user #{user.inspect} raised error: #{err.message}"
    Airbrake.notify err
  end

  #
  # private
  #

  def run_json_setters(instance, node)
    runner = Stretched::Script.runner(user: user)
    runner.set_context(
      doc:             node,
      page:            context.page,
      browser_session: context.browser_session,
      user:            user
    )
    read_with_json(
      runner: runner,
      instance: instance
    )
  end

  def run_ruby_setters(instance, node)
    return instance unless adapter.scripts
    adapter.runners.each do |runner|
      runner.set_context(
        doc:             node,
        page:            context.page,
        browser_session: context.browser_session,
        user:            user
      )
      instance = read_with_script(
        runner: runner,
        instance: instance
      )
    end
    instance
  end

  def read_with_json(opts)
    runner, instance = opts[:runner], opts[:instance]
    adapter.attribute_setters.each do |attribute_name, setters|
      raise "Property #{attribute_name} is not defined in schema #{adapter.schema_key} for user #{user}" unless adapter.validate_property(attribute_name)
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

    instance
  end

  def read_with_script(opts)
    runner, instance = opts[:runner], opts[:instance]
    runner.attributes.each do |attribute_name, value|
      raise "Property #{attribute_name} is not defined in schema #{adapter.schema_key} for user #{user}" unless adapter.validate_property(attribute_name)
      result = value.is_a?(Proc) ? value.call(instance) : value
      instance[attribute_name.to_s] = result
    end

    instance
  end

  def clean_up(result)
    return result unless result.is_a?(String)
    return unless result = ActionView::Base.full_sanitizer.sanitize(result, tags: [])
    result = HTMLEntities.new.decode(result)
    result = result.strip.squeeze(" ") rescue nil
    result.present? ? result : nil
  end
end
