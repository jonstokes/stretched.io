class ExtractDocumentFromNode
  include Interactor::Organizer
  include Troupe

  organize RunJsonSetters, RunScriptSetters, ValidateProperties, BuildDocument
end
