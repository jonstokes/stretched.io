class RunSetters
  include Interactor::Organizer

  organize RunJsonSetters, RunScriptSetters, ValidateResults, BuildDocument
end