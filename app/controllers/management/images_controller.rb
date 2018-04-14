class Management::ImagesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :accessible_images
  before_filter :setup_king_pc_vars

  layout 'main'

  def index
    @images = accessible_images.get_page(params[:page])
  end

  def show
    @image = accessible_images.find(params[:id])
    if @image.image_type == SpecialCode.get_code('image_type','kingdom')
      @type = "feature"
    elsif @image.image_type == SpecialCode.get_code('image_type','creature') ||
          @image.image_type == SpecialCode.get_code('image_type','character')
      @type = "creture"
    elsif @image.image_type == SpecialCode.get_code('image_type','world')
      @type = "world_feature"
    else
      flash[:notice] = "Pretag was not set. This could cause a few prblems."
    end
  end

  def new
    if params[:image]
      @image = accessible_images.new(image_params.merge(
                                       player_id: current_player.id))
    else
      @image = accessible_images.new
    end

    @types = SPEC_CODET['image_type']
    unless current_player.admin
      @types.delete('world')
      @types.delete('character')
    end
    set_image_box_size
  end

  def create
    new
    
    #take care of cropping the image
    if @image.image_type == SpecialCode.get_code('image_type','kingdom') || 
       @image.image_type == SpecialCode.get_code('image_type','world')
      @image.resize_image(10,15)
    end
    
    if @image.save
      flash[:notice] = @image.name + ' was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @image = accessible_images.find(params[:id])
    set_image_box_size
    @types = SPEC_CODET['image_type']
    unless current_player.admin
      @types.delete('world')
      @types.delete('character')
    end
    if !verify_image_owner
      redirect_to :action => 'index'
      return
    end
  end

  def update
    edit
    
    if @image.update_attributes(image_params)
      if @image.image_type == SpecialCode.get_code('image_type','kingdom') || 
         @image.image_type == SpecialCode.get_code('image_type','world')
        @image.resize_image(10,15)
        @image.save!
      end
      flash[:notice] = @image.name + ' was successfully updated.'
      redirect_to :action => 'show', :id => @image
    else
      edit
      render :action => 'edit'
    end
  end

  def destroy
    @image = Image.find(params[:id])
    if !verify_image_owner || !verify_image_not_in_use
      redirect_to :action => 'index', :page => params[:page]
      return
    end
  
    if @image.destroy
      flash[:notice] = 'Image was destroyed'
      redirect_to :action => 'index', :page => params[:page]
    end
  end
  
protected
  def set_image_box_size
    if @image.image_type && (@image.image_type == SpecialCode.get_code('image_type','kingdom') || 
                              @image.image_type == SpecialCode.get_code('image_type','world'))
      @image_box = 2
    else
      @image_box = 1
    end
  end

  def verify_image_owner
    #if someone tries to edit an image not belonging to the kingdom
    if @image.kingdom_id != session[:kingdom][:id]
      flash[:notice] = 'An error occured while retrieving ' + @image.name
      false
    else
      true
    end
  end
  
  #dont destroy an image that is beign used is basically what this boilds down to
  def verify_image_not_in_use
    if @image.player_characters.size > 0 || @image.creatures.size > 0 || @image.features.size > 0
      flash[:notice] = 'Cannot delete "' + @image.name + '", it is in use.'
      false
    else
      true
    end
  end

  def accessible_images
    if current_player.admin
      @accessible_images ||= session[:kingdom].images
    else
      @accessible_images ||= session[:kingdom].images.where.not(
          image_type: [
                          SpecialCode.get_code('image_type','character'),
                          SpecialCode.get_code('image_type','world')
                      ])
    end
  end

  protected

  def image_params
    params.require(:image).permit(
        :name, :image_text, :public, :image_type, :picture
    )
  end
end
