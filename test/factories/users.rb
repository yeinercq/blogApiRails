FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    # el auth_token es manejada por le servicio de generación de token
  end
end
