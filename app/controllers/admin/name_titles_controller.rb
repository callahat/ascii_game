class Admin::NameTitlesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_name_title, only: [:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @name_titles = NameTitle.get_page(params[:page])
  end

  def new
    @name_title = NameTitle.new
    @stats = ["","all","con","dam","dex","dfn","int","mag","str"]
  end

  def create
    @name_title = NameTitle.new(name_title_params)
    @stats = ["","all","con","dam","dex","dfn","int","mag","str"]
    if @name_title.save
      flash[:notice] = 'NameTitle was successfully created.'
      redirect_to admin_name_titles_path
    else
      render :action => 'new'
    end
  end

  def edit
    @stats = ["","all","con","dam","dex","dfn","int","mag","str"]
  end

  def update
    if @name_title.update_attributes(name_title_params)
      flash[:notice] = 'NameTitle was successfully updated.'
      redirect_to admin_name_titles_path
    else
      @stats = ["","all","con","dam","dex","dfn","int","mag","str"]
      render :action => 'edit'
    end
  end

  def destroy
    @name_title.destroy
    redirect_to admin_name_titles_path
  end

  protected

  def name_title_params
    params.require(:name_title).permit(:title,:stat,:points)
  end

  def set_name_title
    @name_title = NameTitle.find(params[:id])
  end
end
