class Admin::WorldMapsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  before_filter :load_world
  before_filter :load_bigxpos_bigypos, only: [:show,:edit,:update] #,:destroy]

  layout 'admin'

  def index
  end

  def show
  end

  def new
  end

  def create
    @bigx,@bigy = params[:map][:loc].split(',')

    Rails.logger.info "Creating world map at: #{@bigx} by #{@bigy}"

    #generate the empty squares for the submap
    gen_world_map_squares(@bigx, @bigy)
    flash[:notice] = 'Generated squares for ' + @bigx + ' by ' + @bigy
    redirect_to admin_world_maps_path(@world)
  end
  
  
  def edit
    setup_features_array
  end
  
  
  def update
    setup_features_array
      
    1.upto(@world.maxy) do |y|
      1.upto(@world.maxx) do |x|
        @temp = @world.world_maps.where(bigypos: @bigypos, bigxpos: @bigxpos, ypos: y, xpos: x).last
        #print "\n#{@temp.id}  #{@temp.nil?} #{@temp.feature_id} #{@temp.feature_id.to_i != params[:map][@y.to_s][@x.to_s].to_i} #{params[:map][@y.to_s][@x.to_s]}\n"
        
        #Destroy the level map if it has changed, and make a new one. 
        #Might want to timestamp this later.
        #but for now, just return the array of those level_maps, and get the last,
        #which should be the latest edit to the contents of that square.
        if @temp.feature_id.to_i != params[:map][y.to_s][x.to_s].to_i &&
           (@temp.feature.nil? || @temp.feature.name[0..0] != "\n")
          @temp = WorldMap.new
          @temp.world_id = @world.id
          @temp.xpos = x
          @temp.ypos = y
          @temp.bigxpos = @bigxpos
          @temp.bigypos = @bigypos
          
          @temp.feature_id = params[:map][y.to_s][x.to_s]
          @temp.save
        end
      end
    end
      
    flash[:notice] = 'Section of the world was successfully updated.'
    redirect_to admin_world_map_path(@world, id: "#{@bigxpos}x#{@bigypos}")
  end

  #Not only is this not good, the way the code is right now, it would leave all those
  #level_maps just dangling out  there with no parent level. BAD.
  #
  #def destroy
  #  @level = Level.find(params[:id])
  #  if !verify_level_owner
  #    redirect_to :action => 'levels'
  #    return
  #  end
  #  
  #  @level.destroy
  #  redirect_to :action => 'index'
  #end
  
protected
  def gen_world_map_squares(bigx,bigy)
    #now, create the level map squares

    1.upto(@world.maxy) do |y|
      1.upto(@world.maxx) do |x|
        temp = WorldMap.new
        temp.world_id = @world.id
        temp.xpos = x
        temp.ypos = y
        temp.bigxpos = bigx
        temp.bigypos = bigy
        temp.feature_id = nil
        
        temp.save
      end
    end
  end
  
  def setup_features_array
    ##make the list of features, for the world, just going to sink the non prefs to end of the array
    @allf = Feature.where(world_feature: true, armed: true)
    @lpref = Kingdom.find(-1).pref_list_features

    @findex = []
    @features = []
    @lpref.each do |lpref|
      f = lpref.feature
      f.name = f.name[0..11]
      if f.name[12..12] != nil
        f.name = f.name + "..."
      end
      @features << f
      @findex << f.id
    end
    
    
    @allf.each do |f|
      if @findex.index(f.id).nil?
        f.name = f.name[0..11]
        if f.name[12..12] != nil
          f.name = f.name + "..."
        end
        @features << f
      end
    end
    
  end

  def load_world
    @world = World.find(params[:world_id])
  end

  def load_bigxpos_bigypos
    @bigxpos, @bigypos = params[:id].split('x')
  end
end
