class ExtractJsonFromPage
  include Troupe
  include Bellbro::Ringable

  expects  :adapter, :page

  permits  :browser_session

  provides(:documents) do
    begin
      page.doc.xpath(adapter.xpath).map do |node|
        RunSetters.call(
          node:            node,
          page:            page,
          browser_session: browser_session
        ).document
      end
    rescue Nokogiri::XML::XPath::SyntaxError => err
      error "Adapter #{context.adapter_name} from session #{context.stretched_session.inspect} for user #{user.inspect} raised error: #{err.message}"
      Airbrake.notify err
    end
  end
end
