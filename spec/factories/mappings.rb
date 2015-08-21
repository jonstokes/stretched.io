FactoryGirl.define do
  factory :mapping do
    sequence(:id) { |n| "doctype_#{n}"}
    data {{
      dynamic: 'strict',
      properties: {
        title: { type: 'string' },
        price: { type: 'integer' }
      }
    }}
  end
end
