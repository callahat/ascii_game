class Admin::TrainerSkillsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_trainer_skill, only: [:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @trainer_skills = TrainerSkill.get_page(params[:page])
  end

  def new
    @trainer_skill = TrainerSkill.new
  end

  def create
    @trainer_skill = TrainerSkill.new(trainer_skill_params)
    if @trainer_skill.save
      flash[:notice] = 'TrainerSkill was successfully created.'
      redirect_to admin_trainer_skills_path
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @trainer_skill.update_attributes(trainer_skill_params)
      flash[:notice] = 'TrainerSkill was successfully updated.'
      redirect_to admin_trainer_skills_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @trainer_skill.destroy
    redirect_to admin_trainer_skills_path
  end

  protected

  def trainer_skill_params
    params.require(:trainer_skill).permit(:max_skill_taught,:min_sales)
  end

  def set_trainer_skill
    @trainer_skill = TrainerSkill.find(params[:id])
  end
end
