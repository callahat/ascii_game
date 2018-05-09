class Admin::WorldsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_world, only: [:show,:edit,:update]
  
  layout 'admin'

  def index
    @worlds = World.get_page(params[:page])
  end

  def show
  end

  def new
    @world = World.new
  end

  def create
    @world = World.new(world_params)
    if @world.save
      flash[:notice] = 'World was successfully created.'
      redirect_to [:admin,@world]
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @world.update_attributes(world_params)
      flash[:notice] = 'World was successfully updated.'
      redirect_to [:admin,@world]
    else
      render :action => 'edit'
    end
  end

  # def destroy
  #  World.find(params[:id]).destroy
  #  redirect_to :action => 'list'
  # end

  protected

  def world_params
    params.require(:world).permit(:name,:minbigx,:minbigy,:maxbigx,:maxbigy,:maxx,:maxy,:text)
  end

  def set_world
    @world = World.find(params[:id])
  end
end
