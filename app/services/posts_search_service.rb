# este serivicio es creado para hacer el filtrado de busqueda según el parámetro :seach
class PostsSearchService
	def self.search(current_posts, query)
		current_posts.where("title like '%#{query}%'")
	end
end