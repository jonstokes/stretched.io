FactoryGirl.define do
  factory :extension do
    sequence(:name) { |n| "test/extension_#{n}"}
    source {
      <<-EOS
        Extension.define #{name} do
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
