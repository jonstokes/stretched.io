class SaveDocuments
  include Troupe

  expects :documents

  def call
    # FIXME: Use bulk write API
    documents.select(&:valid?).map(&:save)  end
  end
