class User < ApplicationRecord
	has_many :posts
	validates :email, presence: true
	validates :name, presence: true
	validates :auth_token, presence: true

	# se ejecuta despues que el objeto se inicielice (User.new)
	after_initialize :generate_auth_token

	def generate_auth_token
		unless auth_token.present?
			# generate token
			self.auth_token = TokenGenerationService.generate # hacemos el llamado a método de la classe (servicio)
		end
	end
end
