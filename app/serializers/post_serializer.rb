class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :published, :author #como author no pertenece a la estructura de post, se define

  def author
  	user = self.object.user
  	{
  		name: user.name,
  		email: user.email,
  		id: user.id
  	}
  end
end
