FactoryGirl.define do
  factory :extension do
    sequence(:id) { |n| "test/extension_#{n}"}
    source {
      <<-EOS
        Extension.define("#{id}") do
          extension do
            def downcase(str)
              str.try(:downcase)
            end
          end
        end
      EOS
    }
  end
end
