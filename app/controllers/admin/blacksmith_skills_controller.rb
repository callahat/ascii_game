class Admin::BlacksmithSkillsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @blacksmith_skills = BlacksmithSkill.get_page(params[:page])
  end

  def show
    @blacksmith_skill = BlacksmithSkill.find(params[:id])
  end

  def new
    @blacksmith_skill = BlacksmithSkill.new
  end

  def create
    @blacksmith_skill = BlacksmithSkill.new(params[:blacksmith_skill])
    if @blacksmith_skill.save
      flash[:notice] = 'Blacksmith Skill was successfully created.'
      redirect_to admin_blacksmith_skill_path(@blacksmith_skill)
    else
      render new_admin_blacksmith_skill_path
    end
  end

  def edit
    @blacksmith_skill = BlacksmithSkill.find(params[:id])
  end

  def update
    @blacksmith_skill = BlacksmithSkill.find(params[:id])
    if @blacksmith_skill.update_attributes(params[:blacksmith_skill])
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
end
