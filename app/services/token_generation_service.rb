class TokenGenerationService
	def self.generate
		# metodo de rails que genera objetos aleatorios
		SecureRandom.hex
	end
end