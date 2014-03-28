class Admin::DiseasesController < ApplicationController
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
    @diseases = Disease.get_page(params[:page])
  end

  def show
    @disease = Disease.find(params[:id])
  end

  def new
    @disease = Disease.new
  end

  def create
    @disease = Disease.new(params[:disease])
    if @disease.save
      flash[:notice] = 'Disease was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @disease = Disease.find(params[:id])
  end

  def update
    @disease = Disease.find(params[:id])
    if @disease.update_attributes(params[:disease])
      flash[:notice] = 'Disease was successfully updated.'
      redirect_to :action => 'show', :id => @disease
    else
      render :action => 'edit'
    end
  end

  def destroy
    Disease.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
