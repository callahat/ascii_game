class Admin::BlacksmithSkillsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_blacksmith_skill, only: [:show,:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @blacksmith_skills = BlacksmithSkill.get_page(params[:page]).includes(:base_item)
  end

  def show
  end

  def new
    @blacksmith_skill = BlacksmithSkill.new
  end

  def create
    @blacksmith_skill = BlacksmithSkill.new(blacksmith_skill_params)
    if @blacksmith_skill.save
      flash[:notice] = 'Blacksmith Skill was successfully created.'
      redirect_to admin_blacksmith_skill_path(@blacksmith_skill)
    else
      render new_admin_blacksmith_skill_path
    end
  end

  def edit
  end

  def update
    if @blacksmith_skill.update_attributes(blacksmith_skill_params)
      flash[:notice] = 'Blacksmith Skill was successfully updated.'
      redirect_to admin_blacksmith_skill_path(@blacksmith_skill)
    else
      render :action => 'edit'
    end
  end

  def destroy
    BlacksmithSkill.find(params[:id]).destroy
    redirect_to admin_blacksmith_skills_path
  end

  protected

  def blacksmith_skill_params
    params.require(:blacksmith_skill).permit(:base_item_id, :min_sales, :min_mod, :max_mod)
  end

  def set_blacksmith_skill
    @blacksmith_skill = BlacksmithSkill.find(params[:id])
  end
end
