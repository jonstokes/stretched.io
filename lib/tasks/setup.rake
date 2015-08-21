namespace :index do
  task delete: :environment do
    puts "Deleting #{INDEX_NAME}..."
    Index.delete
  end

  task create: :environment do
    puts "Creating #{INDEX_NAME}..."
    Index.create
  end
end
