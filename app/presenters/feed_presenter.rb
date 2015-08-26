class FeedPresenter < BasePresenter
  def pages_count
    pages.count
  end

  def documents_count
    pages.sum { |p| p.documents.count }
  end
end