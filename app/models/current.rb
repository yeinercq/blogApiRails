# Guardamos el contexto que será accesible por la sesión actual
class Current < ActiveSupport::CurrentAttributes
	attribute :user
end