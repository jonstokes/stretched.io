MAPPED_CLASSES = %w(adapter document domain extension feed page rate_limit schema script)

namespace :index do
  task delete: :environment do
    puts "Deleting #{INDEX_NAME}..."
    Elasticsearch::Persistence.client.indices.delete(index: INDEX_NAME)
  end

  task create: :environment do
    puts "Creating #{INDEX_NAME}..."
    Elasticsearch::Persistence.client.indices.create(
      index: INDEX_NAME,
      body:  {
        settings: {},
        mappings: Hash[
          MAPPED_CLASSES.map { |k| [k, k.classify.constantize.mapping]}
        ]
      }
    ) rescue nil

    MAPPED_CLASSES.each do |k|
      klass = k.classify.constantize
      if klass.respond_to?(:clear_redis)
        klass.clear_redis
      end
    end
  end
end
