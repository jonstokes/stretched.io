class BasePresenter < SimpleDelegator
  def initialize(model, view=nil)
    @model, @view = model, view
    super(@model)
  end

  def h
    @view
  end
end