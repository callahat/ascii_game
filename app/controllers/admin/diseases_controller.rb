class Admin::DiseasesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @diseases = Disease.get_page(params[:page])
  end

  def show
    @disease = Disease.find(params[:id])
  end

  def new
    @disease = Disease.new
    @disease.build_stat
  end

  def create
    @disease = Disease.new(params[:disease])
    if @disease.save
      flash[:notice] = 'Disease was successfully created.'
      redirect_to admin_disease_path(@disease)
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
      redirect_to admin_disease_path(@disease)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Disease.find(params[:id]).destroy
    redirect_to admin_diseases_path
  end
end
