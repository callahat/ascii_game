class Admin::TrainerSkillsController < ApplicationController
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
    @trainer_skills = TrainerSkill.get_page(params[:page])
  end

  def show
    @trainer_skill = TrainerSkill.find(params[:id])
  end

  def new
    @trainer_skill = TrainerSkill.new
  end

  def create
    @trainer_skill = TrainerSkill.new(params[:trainer_skill])
    if @trainer_skill.save
      flash[:notice] = 'TrainerSkill was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @trainer_skill = TrainerSkill.find(params[:id])
  end

  def update
    @trainer_skill = TrainerSkill.find(params[:id])
    if @trainer_skill.update_attributes(params[:trainer_skill])
      flash[:notice] = 'TrainerSkill was successfully updated.'
      redirect_to :action => 'show', :id => @trainer_skill
    else
      render :action => 'edit'
    end
  end

  def destroy
    TrainerSkill.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
