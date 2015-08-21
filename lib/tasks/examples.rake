namespace :examples do
  namespace :news do
    task load: :environment do
      Index.delete rescue nil
      sleep 1
      Index.create
      Index.refresh

      puts "Loading news registrations into #{INDEX_NAME}..."

      File.open(Rails.root.join('examples', 'news', 'mappings.json')) do |f|
        JSON.parse(f.read)['mappings'].each do |id, data|
          Mapping.create(data.merge(id: id))
        end
      end

      File.open(Rails.root.join('examples', 'news', 'article.json')) do |f|
        Schema.create(name: 'Article', data: JSON.parse(f.read))
      end

      File.open(Rails.root.join('examples', 'news', 'normalize_properties.rb')) do |f|
        Script.create(name: 'global/normalize_properties', source: f.read)
      end

      File.open(Rails.root.join('examples', 'news', 'normalizations.rb')) do |f|
        Extension.create(name: 'global/normalizations', source: f.read)
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

    task run_feeds: :environment do
      Feed.each_stale do |feed|
        RunFeedWorker.new.perform(feed_id: feed.id)
      end
    end
  end
end
