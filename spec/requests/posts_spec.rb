require 'rails_helper' # aquí estan las conficuraciones de rspec

# prueba de integración por :request
RSpec.describe "posts", type: :request do
	
	describe "GET /posts" do

		it "should return OK" do
			get "/posts"
			payload = JSON.parse(response.body) # obtenemos el payload del cuerpo de la respuesta
			expect(payload).to be_empty
			expect(response).to have_http_status(200)
		end

		describe "search" do
			# let() es de rspec & create_list() es de factory boot.
			# El ! en let!() permite que el metodo sea ejecutado de primero antes de la validación
			# y no cuando sea llamado el objeto en la ejecución del test 
			let!(:hola_mundo) { create(:published_post, title: "Hola mundo") } 
			let!(:hola_rails) { create(:published_post, title: "Hola rails") }
			let!(:curso_rails) { create(:published_post, title: "Curso rails") }
			
			it "should filter post by titile" do
				get "/posts?search=Hola"
				payload = JSON.parse(response.body)
				expect(payload).not_to be_empty
				expect(payload.map { |p| p["id"] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)
				expect(response).to have_http_status(200)
			end
		end
	end
	
	describe "with data un DB" do
		let!(:posts) { create_list(:post, 10, published: true) } #let() es de rspec & create_list() es de factory boot
		
		it "should return all published posts" do
			get "/posts"
			payload = JSON.parse(response.body)
			expect(payload.size).to eq(posts.size)
			expect(response).to have_http_status(200)
		end
	end

	describe "GET /posts/{id}" do
		let!(:post) { create(:post, published: true) } #let() es de rspec & create_list() es de factory boot
		
		it "should return all published posts" do
			get "/posts/#{post.id}"
			payload = JSON.parse(response.body)
			expect(payload).not_to be_empty
			expect(payload["id"]).to eq(post.id)
			expect(payload["title"]).to eq(post.title)
			expect(payload["content"]).to eq(post.content)
			expect(payload["published"]).to eq(post.published)
			expect(payload["author"]["name"]).to eq(post.user.name)
			expect(payload["author"]["email"]).to eq(post.user.email)
			expect(payload["author"]["id"]).to eq(post.user.id)
			expect(response).to have_http_status(200)
		end
	end
end