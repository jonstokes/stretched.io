require 'spec_helper'
require 'webmock/rspec'

describe ExtractJsonFromPage do

  describe "#call" do
    it "adds an empty JSON object for an invalid page" do
      Mocktra(@domain) do
        get '/products/1' do
          "<html><head></head><body>Invalid Listing!</body></html>"
        end
      end

      page = @connection.get_page(@product_url)
      result = ExtractJsonFromPage.call(
        page: page,
        adapter: Document::Adapter.find("www.retailer.com/product_page", @user)
      )

      expect(result.json_objects.size).to eq(1)
    end

    it "should translate a page into JSON using a JSON adapter" do
      Mocktra(@domain) do
        get '/products/1' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/product1.html") do |file|
            file.read
          end
        end
      end

      page = @connection.get_page(@product_url)

      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("www.retailer.com/product_page_no_script", @user)
      )

      expect(result.json_objects).not_to be_empty

      listing = result.json_objects.first
      expect(listing['title']).to include("Ruger 3470 SR40 15+1 40S&")
      expect(listing['keywords']).to include("Ruger, 3470")
      expect(listing['image']).to eq("http://www.retailer.com/catalog/images/69980_1.jpg")
      expect(listing['sale_price_in_cents']).to be_nil
    end

    it "should translate a page into JSON using a script" do
      Mocktra(@domain) do
        get '/products/1' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/product1.html") do |file|
            file.read
          end
        end
      end

      page = @connection.get_page(@product_url)

      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("www.retailer.com/product_page_scripts_only", @user)
      )

      expect(result.json_objects).not_to be_empty

      listing = result.json_objects.first
      expect(listing['title']).to include("Ruger 3470 SR40 15+1 40S&")
      expect(listing['type']).to eq("RetailListing")
      expect(listing['image']).to eq("http://www.retailer.com/catalog/images/69980_1.jpg")
      expect(listing['location']).to be_nil
    end

    it "should translate a page into JSON using JSON and scripts combined" do
      Mocktra(@domain) do
        get '/products/1' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/product1.html") do |file|
            file.read
          end
        end
      end

      page = @connection.get_page(@product_url)

      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("www.retailer.com/product_page", @user)
      )

      expect(result.json_objects).not_to be_empty

      listing = result.json_objects.first
      expect(listing['title']).to include("Ruger 3470 SR40 15+1 40S&")
      expect(listing['type']).to eq("RetailListing")
      expect(listing['location']).to eq("1105 Industry Road Lexington, KY 40505")
      expect(listing['image']).to eq("http://www.retailer.com/catalog/images/69980_1.jpg")
      expect(listing['sale_price_in_cents']).to eq(41100)
    end

    it "errors if the JSON adapter has an invalid attribute that doesn't match the schema" do
      Mocktra(@domain) do
        get '/products/1' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/product1.html") do |file|
            file.read
          end
        end
      end

      page = @connection.get_page(@product_url)

      expect {
        ExtractJsonFromPage.call(
          user: @user,
          page: page,
          adapter: Document::Adapter.find("www.retailer.com/product_page_invalid_json_attribute", @user)
        )
      }.to raise_error(RuntimeError, "Property listing_type is not defined in schema Listing for user test@ironsights.com")
    end

    it "errors if the script has an invalid attribute that doesn't match the schema" do
      Mocktra(@domain) do
        get '/products/1' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/product1.html") do |file|
            file.read
          end
        end
      end

      Stretched::Script.create_from_file("spec/fixtures/registrations/scripts/www--retailer--com/invalid_script.rb", @user)
      page = @connection.get_page(@product_url)

      expect {
        ExtractJsonFromPage.call(
          user: @user,
          page: page,
          adapter: Document::Adapter.find("www.retailer.com/product_page_invalid_script_attribute", @user)
        )
      }.to raise_error(RuntimeError, "Property listing_type is not defined in schema Listing for user test@ironsights.com")
    end
  end

  describe "various page types" do

    it "parses an invalid listing" do
      domain = "www.hyattgunstore.com"
      url = "http://#{domain}/1.html"
      register_site domain, @user
      Mocktra(domain) do
        get '/1.html' do
          "<html><head></head><body>Invalid Listing!</body></html>"
        end
      end

      page = @connection.get_page(url)
      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("#{domain}/product_page", @user)
      )

      listing = result.json_objects.first
      expect(listing['valid']).to eq(false)
    end

    it "parses a standard, out of stock retail listing from Impact Guns" do
      domain = "www.impactguns.com"
      register_site domain, @user
      url = "http://#{domain}/1.html"
      Mocktra(domain) do
        get '/1.html' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/impact-standard-outofstock.html") do |file|
            file.read
          end
        end
      end
      page = @connection.get_page(url)
      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("#{domain}/product_page", @user)
      )

      listing = Hashie::Mash.new result.json_objects.first

      expect(listing.valid).to eq(true)
      expect(listing.condition).to eq("new")
      expect(listing.image).to eq("http://www.impactguns.com/data/default/images/catalog/535/REM_22CYCLONE_CASE.jpg")
      expect(listing.keywords).to eq("Remington, Remington 22LR CYCLONE 36HP 5000 CAS, 10047700482016")
      expect(listing.description).to include("Remington-Remington")
      expect(listing.price_in_cents).to be_nil
      expect(listing.sale_price_in_cents).to be_nil
      expect(listing.current_price_in_cents).to be_nil
      expect(listing.availability).to eq("out_of_stock")
      expect(listing.location).to eq("2710 South 1900 West, Ogden, UT 84401")
    end

    it "parses a classified listing from Armslist" do
      domain = "www.armslist.com"
      register_site domain, @user
      url = "http://#{domain}/1.html"

      Mocktra(domain) do
        get '/1.html' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/armslist.html") do |file|
            file.read
          end
        end
      end

      page = @connection.get_page(url)
      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("#{domain}/product_page", @user)
      )

      listing = Hashie::Mash.new result.json_objects.first

      expect(listing.valid).to eq(true)
      expect(listing.product_category1).to eq("Guns")
      expect(listing.title).to eq("fast sale springfield xd 45")
      expect(listing.condition).to be_nil
      expect(listing.image).to eq("http://cdn2.armslist.com/sites/armslist/uploads/posts/2013/05/24/1667211_01_fast_sale_springfield_xd_45_640.jpg")
      expect(listing.keywords).to be_nil
      expect(listing.description).to include("For sale a springfield xd")
      expect(listing.price_in_cents).to eq(52500)
      expect(listing.sale_price_in_cents).to be_nil
      expect(listing.current_price_in_cents).to eq(52500)
      expect(listing.availability).to eq("in_stock")
      expect(listing.location).to include("Southwest Washington")
    end

    it "parses a CTD retail listing using meta tags" do
      domain = "www.cheaperthandirt.com"
      register_site domain, @user
      url = "http://#{domain}/1.html"
      Mocktra(domain) do
        get '/1.html' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/ctd-meta-tags.html") do |file|
            file.read
          end
        end
      end
      page = @connection.get_page(url)
      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("#{domain}/product_page", @user)
      )
      listing = Hashie::Mash.new result.json_objects.first

      expect(listing.valid).to eq(true)
      expect(listing.description).to include("Lightfield offers many great hunting")
      expect(listing.image).to eq("http://cdn1.cheaperthandirt.com/ctd_images/mdprod/3-0307867.jpg")
      expect(listing.price_in_cents).to eq(1221)
    end

    it "parses a BGS retail listing using meta_og tags" do
      domain = "www.retailer.com"
      register_site domain, @user
      url = "http://#{domain}/1.html"
      Mocktra(domain) do
        get '/1.html' do
          File.open("#{Rails.root}/spec/fixtures/web_pages/bgs-metaog-tags.html") do |file|
            file.read
          end
        end
      end
      page = @connection.get_page(url)
      result = ExtractJsonFromPage.call(
        user: @user,
        page: page,
        adapter: Document::Adapter.find("#{domain}/product_page", @user)
      )
      listing = Hashie::Mash.new result.json_objects.first

      expect(listing.valid).to eq(true)
      expect(listing.not_found).to be_nil
      expect(listing.title).to eq("Silva Olive Drab Compass")
      expect(listing.image).to eq("http://www.retailer.com/catalog/images/15118.jpg")
    end

  end
end
