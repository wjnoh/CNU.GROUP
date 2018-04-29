require "Common_controller_module"
class FreeBoardController < ApplicationController
  include SetWriter
  before_action :authenticate_user! , except: [:new, :searchList]

  def new
    @posts = Freepost.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    @choosenPostID = params[:postID].to_i unless params[:postID].nil?
    linkStatus = params[:link]

    if linkStatus == "go"
      countAboveChoosenPost = 0
      Freepost.all.reverse.each do |post|
        if @choosenPostID >= post.id
          break
        else
          countAboveChoosenPost = countAboveChoosenPost + 1
        end
      end
      page = (countAboveChoosenPost / 10.0).floor + 1

      return redirect_to "/freeBoard/#{@choosenPostID}?page=#{page}"
    end

    render "/anony/posts"
  end


  def create
    setWriter
    post = Freepost.create(user_id: current_user.id, writer: @writer, title: params[:createTitle],
                              content: params[:createContent], category: params[:crateCategory])
    return redirect_to "/freeBoard"
  end


  def update
    post = Freepost.find(params[:postID])
    post.update_attributes(title: params[:updateTitle], content: params[:updateContent], category: params[:updateCategory])
    return redirect_to "/freeBoard"
  end


  def destroy
    post = Freepost.find(params[:postID])
    post.replies.each do |reply|
      reply.destroy
    end
    post.destroy

    return redirect_to "/freeBoard"
  end


  def searchList
    @searchContent = params[:searchContent]
    @searchCategory = params[:searchCategory]
    @posts = Freepost.where("title LIKE ? " , "%#{@searchContent}%" ).order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    if @posts.empty?
      render "/anony/searchEmpty"
    else
      render "/anony/posts"
    end
  end

end
