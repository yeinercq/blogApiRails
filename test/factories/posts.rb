FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published {
    	r = rand(0..1)
    	if r == 0
    		false
    	else
    		true
    	end
    }
    user #la referencia al factory de users
  end

  # este bloque sirve para generar posts con published: true, para no hacerlo aleatorio
  factory :published_post, class: 'Post' do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { true }
    user #la referencia al factory de users
  end
end
