module Index
  MAPPED_CLASSES = %w(adapter domain extension feed page rate_limit schema script)

  def self.client
    Elasticsearch::Persistence.client
  end

  def self.create
    client.indices.create(
      index: name,
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
    client.indices.refresh(index: name)
  end

  def self.delete
    clear_redis
    client.indices.delete(index: name)
  end

  def self.name
    @@index_name ||= Figaro.env.index_name || [Rails.application.engine_name, Rails.env].join('-')
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