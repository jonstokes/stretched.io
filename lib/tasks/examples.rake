namespace :examples do
  namespace :news do
    task load: :environment do
      puts "Loading news registrations into #{INDEX_NAME}..."

      File.open(Rails.root.join('examples', 'news', 'article.json')) do |f|
        Schema.create(id: 'Article', data: JSON.parse(f.read))
      end

      File.open(Rails.root.join('examples', 'news', 'normalize_timestamp.rb')) do |f|
        Script.create(id: 'global/normalize_timestamp', source: f.read)
      end

      File.open(Rails.root.join('examples', 'news', 'normalizations.rb')) do |f|
        Extension.create(id: 'global/normalizations', source: f.read)
      end

      YAML.load_file(Rails.root.join('examples', 'news', 'rate_limits.yaml')).each do |attrs|
        RateLimit.create(attrs)
      end

      YAML.load_file(Rails.root.join('examples', 'news', 'domains.yaml')).each do |attrs|
        Domain.create(attrs)
      end

      YAML.load_file(Rails.root.join('examples', 'news', 'adapters.yaml')).each do |attrs|
        Adapter.create(attrs)
      end

      YAML.load_file(Rails.root.join('examples', 'news', 'feeds.yaml')).each do |attrs|
        feed = Feed.create(attrs)
        feed.link_pages
      end
    end
  end
end
