class Admin::DiseasesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_disease, only: [:show,:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @diseases = Disease.get_page(params[:page]).includes(:stat)
  end

  def show
  end

  def new
    @disease = Disease.new
    @disease.build_stat
  end

  def create
    @disease = Disease.new(disease_params)
    if @disease.save
      flash[:notice] = 'Disease was successfully created.'
      redirect_to admin_disease_path(@disease)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @disease.update_attributes(disease_params)
      flash[:notice] = 'Disease was successfully updated.'
      redirect_to admin_disease_path(@disease)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @disease.destroy
    redirect_to admin_diseases_path
  end

  protected

  def disease_params
    params.require(:disease).permit(
        :name,
        :description,
        :virility,
        :trans_method,
        :HP_per_turn,
        :MP_per_turn,
        :peasant_fatality,
        :min_peasants,
        stat_attributes: [:str, :dex, :con, :int, :mag, :dfn, :dam])
  end

  def set_disease
    @disease = Disease.find(params[:id])
  end
end
