class Admin::NameSurfixesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :list }

  def list
    @name_surfixes = NameSurfix.get_page(params[:page])
  end

  def show
    @name_surfixes = NameSurfixes.find(params[:id])
  end

  def new
    @name_surfixes = NameSurfixes.new
  end

  def create
    @name_surfixes = NameSurfixes.new(params[:name_surfixes])
    if @name_surfixes.save
      flash[:notice] = 'NameSurfixes was successfully created.'
      redirect_to :action => 'new'
    else
      render :action => 'new'
    end
  end

  def edit
    @name_surfixes = NameSurfixes.find(params[:id])
  end

  def update
    @name_surfixes = NameSurfixes.find(params[:id])
    if @name_surfixes.update_attributes(params[:name_surfixes])
      flash[:notice] = 'NameSurfixes was successfully updated.'
      redirect_to :action => 'show', :id => @name_surfixes
    else
      render :action => 'edit'
    end
  end

  def destroy
    NameSurfixes.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
