class Admin::HealerSkillsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @healer_skills = HealerSkill.get_page(params[:page])
  end

  def show
    @healer_skill = HealerSkill.find(params[:id])
  end

  def new
    @healer_skill = HealerSkill.new
    @diseases = Disease.all
  end

  def create
    @healer_skill = HealerSkill.new(params[:healer_skill])
    @diseases = Disease.all
    if @healer_skill.save
      flash[:notice] = 'HealerSkill was successfully created.'
      redirect_to admin_healer_skill_path(@healer_skill)
    else
      render :action => 'new'
    end
  end

  def edit
    @healer_skill = HealerSkill.find(params[:id])
    @diseases = Disease.all
  end

  def update
    @healer_skill = HealerSkill.find(params[:id])
    @diseases = Disease.all
    if @healer_skill.update_attributes(params[:healer_skill])
      flash[:notice] = 'HealerSkill was successfully updated.'
      redirect_to admin_healer_skill_path(@healer_skill)
    else
      render :action => 'edit'
    end
  end

  def destroy
    HealerSkill.find(params[:id]).destroy
    redirect_to admin_healer_skills_path
  end
end
