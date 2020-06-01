class PostReportJob < ApplicationJob
  queue_as :default

  # user pide un reporte de un post -> enviamos reporte
  def perform(user_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    report = PostReport.generte(post)
  end
end
