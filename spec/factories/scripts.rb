FactoryGirl.define do
  factory :script do
    transient       { extension { create(:extension) } }
    sequence(:name) { |n| "test/script_#{n}"}
    source          {
      <<-EOS
        Script.define("#{name}") do
          extensions '#{extension.name}'
          script do
            title do |instance|
              downcase(instance['title'])
            end
          end
        end
      EOS
    }
  end
end
