class RunSetters
  include Interactor::Organizer
  include Troupe

  organize RunJsonSetters, RunScriptSetters, ValidateResults, BuildDocument
end
