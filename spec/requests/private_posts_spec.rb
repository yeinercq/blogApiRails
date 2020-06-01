require 'rails_helper' # aquí estan las conficuraciones de rspec
require "byebug"
# prueba de integración por :request
RSpec.describe "Posts with authentication", type: :request do
	
	let!(:user) { create(:user) }
	let!(:other_user) { create(:user) }
	let!(:user_post) { create(:post, user_id: user.id) }
	let!(:other_user_post) { create(:post,  user_id: other_user.id, published: true) }
	let!(:other_user_post_draft) { create(:post,  user_id: other_user.id, published: false) }
	# Para hacer un request con auth, generalmente se usa un header para especificar el token
	# Authorizationn: Bearer 'token' -> estandar de openOAuth
	let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
	let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }

	let!(:create_params) { { "post" => { "title" => "title", "content" => "content", "published" => true } } }
	let!(:update_params) { { "post" => { "title" => "New title", "content" => "New content", "published" => true } } }
	
	describe "GET /posts/{id}" do
		context "with valid authentication" do
			context "when requisting other's author post" do
				context "when post is public" do
					# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
					before { get "/posts/#{other_user_post.id}", headers: auth_headers }
					
					# payload
					context "payload" do
						subject { payload } # proveemos un sujeto de pruebas
						it { is_expected.to include(:id) }
					end
					# response
					context "response" do
						subject { response } # proveemos un sujeto de pruebas
						it { is_expected.to have_http_status(:ok) }
					end
				end

				context "when post is draft" do
					# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
					before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }
					
					# payload
					context "payload" do
						subject { payload } # proveemos un sujeto de pruebas
						it { is_expected.to include(:error) }
					end
					# response
					context "response" do
						subject { response } # proveemos un sujeto de pruebas
						it { is_expected.to have_http_status(:not_found) }
					end
				end
			end

			context "when requisting user's post" do
			end
		end
	end

	describe "POST /posts" do
		# con auth -> crear
		context "with valid auth" do
			# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
			before { post "/posts", params: create_params, headers: auth_headers }
			# payload
			context "payload" do
				subject { payload } # proveemos un sujeto de pruebas
				it { is_expected.to include(:id, :title, :content, :published, :author) }
			end
			# response
			context "response" do
				subject { response } # proveemos un sujeto de pruebas
				it { is_expected.to have_http_status(:created) }
			end
		end
		# sin auth -> !crear -> 401
		context "without auth" do
			# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
			before { post "/posts", params: create_params }
			# payload
			context "payload" do
				subject { payload } # proveemos un sujeto de pruebas
				it { is_expected.to include(:error) }
			end
			# response
			context "response" do
				subject { response } # proveemos un sujeto de pruebas
				it { is_expected.to have_http_status(:unauthorized) }
			end
		end
	end

	describe "PUT /posts/{id}" do
		# con auth
			# !actualizar un post ajeno
			# actualizar un post propio -> 401
		

		context "with valid auth" do

			context "when updating users's post" do
				# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
				before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }				
				# payload
				context "payload" do
					subject { payload } # proveemos un sujeto de pruebas
					it { is_expected.to include(:id, :title, :content, :published, :author) }
					it { expect(payload[:id]).to eq(user_post.id) }
				end
				# response
				context "response" do
					subject { response } # proveemos un sujeto de pruebas
					it { is_expected.to have_http_status(:ok) }
				end
			end

			context "when updating other users's post" do
				# hacemos la petición a un posts publico y enviamos en el request los headers de authentication
				before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }				
				# payload
				context "payload" do
					subject { payload } # proveemos un sujeto de pruebas
					it { is_expected.to include(:error) }
				end
				# response
				context "response" do
					subject { response } # proveemos un sujeto de pruebas
					it { is_expected.to have_http_status(:not_found) }
				end
			end
		end
	end

	private

	def payload
		JSON.parse(response.body).with_indifferent_access # permite acceder idiferentemente a un hash con :id o "id" -> metodo de rails
	end
		#it "should return OK" do
		#	get "/posts"
		#	payload = JSON.parse(response.body)
		#	expect(payload).to be_empty
		#	expect(response).to have_http_status(200)
		#end
end