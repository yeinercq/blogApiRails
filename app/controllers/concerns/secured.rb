module Secured
	def authenticate_user!
		#Bearer 'token'
		token_regex = /Bearer (\w+)/ # formato del header
		#leer el header de auth
		headers = request.headers
		# verificar que sea valido
		if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
			# al definir el grupo de captura en el 
			# token_regex ((\w+)) podemos acceder a ese grupo con []
			token = headers['Authorization'].match(token_regex)[1]
			# debemos verrificar que el token corresponda a un usuario
			if (Current.user = User.find_by_auth_token(token)) # Current es una función de ruby para que user sea accesible en cualquier contexto de la app, es una clase en el grupo models
				return
			end
		end
		render json: {error: 'Unauthorized'}, status: :unauthorized
	end
end
