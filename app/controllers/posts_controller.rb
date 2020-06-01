class PostsController < ApplicationController
	include Secured
	
	# Cunado se crea una acción que puede modificar el comportamiento normal de un request
	# por convención se usa el signo de admiración
	before_action :authenticate_user!, only: [:create, :update]

	# rescue_from para manejar excepciones: cuando el objeto es inválido por params.
	# Acá manejamos todas la excepciones con Exeption
	rescue_from Exception do |e|
		#log.error "#{e.message}"
		render json: {error: e.message}, status: :internal_error
	end

	rescue_from ActiveRecord::RecordNotFound do |e|
		render json: {error: e.message}, status: :not_found
	end

	# rescue_from para manejar excepciones: cuando el objeto es inválido por params, 
	# arrojamos el status que pusimos en el rspec test
	rescue_from ActiveRecord::RecordInvalid do |e|
		render json: {error: e.message}, status: :unprocessable_entity
	end

	# GET /posts
	def index
		# Filtra los posts que están publicados
		@posts = Post.where(published: true)
		# valida que el parametreo seach no sea nulo y que esté presente para el filtrado de posts
		if !params[:search].nil? && params[:search].present?
			# creamos el metodo PostsSearchService para hacer el filtrado
			@posts = PostsSearchService.search(@posts, params[:search])
		end
		# .inlcudes(:user) sirve para incluir en un solo query todos los users relacionados con @posts 
		# y corregir el N+1 query problem
		render json: @posts.includes(:user), status: :ok
	end

	# GET /posts/{id}
	def show
		@post = Post.find(params[:id])
		if (@post.published? || (Current.user && @post.user_id == Current.user.id))
			render json: @post, status: :ok
		else
			render json: {error: 'Not Found'}, status: :not_found
		end
	end

	# POST /posts
	def create
		# se usa ! para que el método falle cuando el objeto es inválido (invalid params), 
		# lo que arrojará una excepción que podremos manejar con un exception handler
		@post = Current.user.posts.create!(create_params) # tenemos acceso a .posts por el has_many del modelo
		render json: @post, status: :created
	end

	# PUT /posts/{id}
	def update
		@post = Current.user.posts.find(params[:id]) # Solo busca posts del current user
		# se usa ! para que el método falle cuando el objeto es inválido (invalid params), 
		# lo que arrojará una excepción que podremos manejar con un exception handler
		@post.update!(update_params)
		render json: @post, status: :ok
	end

	private

	#para recibir los parametros en un request creamos el metodo params
	def create_params
		params.require(:post).permit(:title, :content, :published)
	end

	#para recibir los parametros en un request creamos el metodo params
	def update_params
		params.require(:post).permit(:title, :content, :published)
	end
end