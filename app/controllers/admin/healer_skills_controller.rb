class Admin::HealerSkillsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_healer_skill, only: [:show,:edit,:update,:destroy]

  layout 'admin'

  def index
    @healer_skills = HealerSkill.get_page(params[:page]).includes(:disease)
  end

  def show
  end

  def new
    @healer_skill = HealerSkill.new
    @diseases = Disease.all
  end

  def create
    @healer_skill = HealerSkill.new(healer_skill_params)
    @diseases = Disease.all
    if @healer_skill.save
      flash[:notice] = 'HealerSkill was successfully created.'
      redirect_to admin_healer_skill_path(@healer_skill)
    else
      render :action => 'new'
    end
  end

  def edit
    @diseases = Disease.all
  end

  def update
    if @healer_skill.update_attributes(healer_skill_params)
      flash[:notice] = 'HealerSkill was successfully updated.'
      redirect_to admin_healer_skill_path(@healer_skill)
    else
      @diseases = Disease.all
      render :action => 'edit'
    end
  end

  def destroy
    @healer_skill.destroy
    redirect_to admin_healer_skills_path
  end

  protected

  def healer_skill_params
    params.require(:healer_skill).permit(
        :max_HP_restore,:max_MP_restore,:disease_id,:max_stat_restore,:min_sales)
  end

  def set_healer_skill
    @healer_skill = HealerSkill.find(params[:id])
  end
end
