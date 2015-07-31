require 'spec_helper'
require 'mocktra'

describe RunSession do
  describe "#call" do

    before :each do
      clear_stretched
      @user = "test@ironsights.com"
      register_globals(@user)
    end

    describe "product pages" do
      before :each do
        @domain = "www.retailer.com"
        register_site @domain, @user
        Stretched::Registration.create_from_file("#{Rails.root}/spec/fixtures/registrations/globals.yml", @user)
        @sessions = YAML.load_file("#{Rails.root}/spec/fixtures/sessions/www--retailer--com.yml")['sessions']
      end

      it "adds an empty JSON object for a 404 page" do
        Mocktra(@domain) do
          get '/products/1' do
            404
          end
        end

        object_q = Document::Queue.new "www.retailer.com/product_links", @user
        expect(object_q.size).to be_zero

        ssn = Session::Session.new(@sessions.last.merge(key: "abcd123", user: @user))
        result = RunSession.call(stretched_session: ssn)

        expect(object_q.size).to eq(2)
        object = object_q.pop
        expect(object[:page]['code']).to eq(404)
        expect(object[:session]['key']).to eq("abcd123")
      end

      it "runs a session and extracts JSON objects from catalog pages" do
        Mocktra(@domain) do
          get '/catalog/1' do
            File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/1911-listing-page.html") do |file|
              file.read
            end
          end
        end

        object_q = Document::Queue.new "www.retailer.com/product_links", @user
        expect(object_q.size).to be_zero

        ssn = Session::Session.new(@sessions.last.merge(user: @user))
        result = RunSession.call(stretched_session: ssn)

        expect(object_q.size).to eq(51)
        expect(result.stretched_session.urls_popped).to eq(2)
      end

      it "runs a session with link expansions and extracts JSON objects from catalog pages" do
        Mocktra(@domain) do
          get '/catalog/1' do
            File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/1911-listing-page.html") do |file|
              file.read
            end
          end
        end

        object_q = Document::Queue.new "www.retailer.com/product_links", @user
        expect(object_q.size).to be_zero

        ssn = Session::Session.new(@sessions.first.merge(user: @user))
        result = RunSession.call(stretched_session: ssn)
        expect(object_q.size).to eq(57)
        expect(result.stretched_session.urls_popped).to eq(8)
        expect(result.stretched_session.urls.size).to eq(0)
      end

      it "times out when the timer is up and adds the session back to the queue" do
        Mocktra(@domain) do
          get '/catalog/1' do
            File.open("#{Rails.root}/spec/fixtures/web_pages/www--retailer--com/1911-listing-page.html") do |file|
              file.read
            end
          end
        end

        timer = RateLimiter.new(1)
        object_q = Document::Queue.new "www.retailer.com/product_links", @user
        expect(object_q.size).to be_zero

        ssn = Session::Session.new(@sessions.first.merge(user: @user))
        result = RunSession.call(stretched_session: ssn, timer: timer)
        expect(object_q.size).to eq(1)
        expect(result.stretched_session.urls_popped).to eq(1)
        expect(result.stretched_session.size).to eq(7)
      end

    end

    describe "product feeds" do

      before :each do
        Stretched::Registration.create_from_file("#{Rails.root}/spec/fixtures/registrations/globals.yml", @user)
        register_site "ammo.net", @user
        @sessions = YAML.load_file("#{Rails.root}/spec/fixtures/sessions/ammo--net.yml")['sessions']
      end

      it "runs a session and extracts objects from product feeds" do
        Mocktra("ammo.net") do
          get '/media/feeds/genericammofeed.xml' do
            File.open("#{Rails.root}/spec/fixtures/rss_feeds/full_product_feed.xml") do |file|
              file.read
            end
          end
        end

        object_q = Document::Queue.new "ammo.net/listings", @user
        expect(object_q.size).to be_zero

        ssn = Session::Session.new(@sessions.first.merge(user: @user))
        result = RunSession.call(stretched_session: ssn)
        expect(result.stretched_session.urls_popped).to eq(1)
        expect(object_q.size).to eq(18)

        json = object_q.pop
        page = json.page
        expect(page.body).to eq(true)
        expect(page.headers).not_to be_nil
        expect(page.code).to eq(200)

        object = json.object
        expect(object.url).to include("ammo.net")
        expect(object.location).to eq("Atlanta, GA 30348")
        expect(object.price_in_cents).not_to be_nil
        expect(object.availability).not_to be_nil
        expect(object.product_category1).to eq("Ammunition")
      end
    end
  end

end
