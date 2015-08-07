class AddDocumentsToQueues
  include Troupe

  expects :documents

  def call
    ActiveRecord::Base.connection_pool.with_connection do
      # FIXME: Should validate docs with empty properties
      documents.select(&:valid?).map(&:save!)
    end
  end
end
