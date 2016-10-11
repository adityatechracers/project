module Admin
  class PostsController < BaseController
    load_and_authorize_resource

    def index
      @posts = Post.not_deleted
    end

    def new
    end

    def create
      respond_to do |format|
        if @post.save
          format.html { redirect_to admin_posts_path, notice: 'Post was successfully created.' }
          format.json { render json: @post, status: :created, location: @post }
        else
          format.html { render action: "new" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      respond_to do |format|
        if @post.update_attributes params[:post]
          format.html { redirect_to admin_posts_path, notice: 'Post was successfully updated.' }
          format.json { render json: @post, status: :created, location: @post }
        else
          format.html { render action: "edit" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @post.destroy

      respond_to do |format|
        format.html { redirect_to admin_posts_path }
        format.json { head :no_content }
      end
    end
  end
end
