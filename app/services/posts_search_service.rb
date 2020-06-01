# este serivicio es creado para hacer el filtrado de busqueda según el parámetro :seach
class PostsSearchService
	def self.search(current_posts, query)
		# Se utiliza Rails.cache para hacer una busqueda de posts y se guerda por una hora el resultado, 
		# se hace una segunda busqueda de posts por ids.
		# En una segunda busqueda solo se ejecuta el query por ids, siempre y cuando el timepo de cache no haya expirado
		posts_ids = Rails.cache.fetch("posts_search/#{query}", expires_in: 1.hours) do
			current_posts.where("title like '%#{query}%'").map(&:id)
		end

		current_posts.where(id: posts_ids)
	end
end