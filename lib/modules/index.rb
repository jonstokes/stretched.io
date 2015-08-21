module Index
  MAPPED_CLASSES = %w(adapter document domain extension feed page rate_limit schema script)

  def self.create
    Elasticsearch::Persistence.client.indices.create(
      index: INDEX_NAME,
      body:  {
        settings: {},
        mappings: Hash[
          MAPPED_CLASSES.map { |k| [k, k.classify.constantize.mapping]}
        ]
      }
    ) rescue nil
    clear_redis
  end

  def self.refresh
    Elasticsearch::Persistence.client.indices.refresh(index: INDEX_NAME)
  end

  def self.delete
    clear_redis
    Elasticsearch::Persistence.client.indices.delete(index: INDEX_NAME)
  end

  def self.clear_redis
    MAPPED_CLASSES.each do |k|
      klass = k.classify.constantize
      if klass.respond_to?(:clear_redis)
        klass.clear_redis
      end
    end
  end
end