MAPPED_CLASSES = %w(adapter document domain extension feed page rate_limit schema script)

def create_index
  Elasticsearch::Persistence.client.indices.create(
    index: INDEX_NAME,
    body:  {
      settings: {},
      mappings: Hash[
        MAPPED_CLASSES.map { |k| [k, k.classify.constantize.mapping]}
      ]
    }
  ) rescue nil
end

def refresh_index
  Elasticsearch::Persistence.client.indices.refresh(index: INDEX_NAME)
end

def delete_index
  Elasticsearch::Persistence.client.indices.delete(index: INDEX_NAME)
end

RSpec.configure do |config|
  config.before(:suite) do
    create_index
  end

  config.before(:each) do
    create_index rescue nil
    refresh_index
    MAPPED_CLASSES.each do |k|
      klass = k.classify.constantize
      if klass.respond_to?(:clear_redis)
        klass.clear_redis
      end
    end
  end

  config.after(:each) do
    delete_index
  end
end
