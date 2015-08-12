FactoryGirl.define do
  factory :script do
    transient { extension { create(:extension) } }
    sequence(:id) { |n| "test/script_#{n}"}
    source {
      <<-EOS
        Script.define("#{id}") do
          extensions '#{extension.id}'
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
