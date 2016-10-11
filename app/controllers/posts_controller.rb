class PostsController < ApplicationController
  layout 'application'

  def index
    @posts = Post.active.order('published_date DESC').page params[:page]
  end

  def show
    @post = Post.active.find_by_slug(params[:post_slug])
    unless @post.present?
      redirect_to blog_path, :alert => "That article couldn't be found."
    end
  end

end
