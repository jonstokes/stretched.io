INDEX_NAME = Figaro.env.index_name || [Rails.application.engine_name, Rails.env].join('-')

Elasticsearch::Persistence.client = Elasticsearch::Client.new(
  host:   'localhost:9200',
  logger: Rails.logger,
  trace:  Rails.env.development?
)
