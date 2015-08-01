FactoryGirl.define do
  factory :script do
    sequence(:name) { |n| "test/script_#{n}"}
    source {
      <<-EOS
        Script.define #{name} do
          extensions 'test/*'
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
