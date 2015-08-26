class DomainPresenter < BasePresenter
  def pages
    feeds.map(&:pages).flatten
  end

  def pages_count
    pages.count
  end

  def documents_count
    pages.sum { |p| p.documents.count }
  end
end