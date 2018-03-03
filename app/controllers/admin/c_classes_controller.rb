class Admin::CClassesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],         :redirect_to => { :action => :list }

  def list
    @c_classes = CClass.get_page(params[:page])
  end

  def show_levels
    # TODO: This doesnt appear to be a valid class anymroe
    @c_class_levels = CClassLevel.where(c_class_id: params[:id])
  end

  def new
    @c_class = CClass.new
  end

  def create
    @c_class = CClass.new(params[:c_class])
    if @c_class.save
      flash[:notice] = 'CClass was successfully created.'
      redirect_to :action => 'first_level', :id => @c_class
    else
      render :action => 'new'
    end
  end

  def edit
    @c_class = CClass.find(params[:id])
  end

  def update
    @c_class = CClass.find(params[:id])
    if @c_class.update_attributes(params[:c_class])
      flash[:notice] = 'CClass was successfully updated. Hit back to keep the level stat settings, or edit to regenerate, which is not recommended if in prod.'
      redirect_to :action => 'edit_first_level', :id => @c_class
    else
      render :action => 'edit'
    end
  end

  def destroy
    #first destroy the related levels
    @cleanup = CClassLevel.where(c_class_id: params[:id])
    clear_cleanup

    if CClass.find(params[:id]).destroy
      flash[:notice] = 'Character class destroyed. <br/>'
    else
      flash[:notice] = 'Character class was not destroyed. <br/>'
    end

    if CClassLevel.where(c_class_id: params[:id]).size == 0
      flash[:notice] += 'Character Class levels destroyed.'
    else
      flash[:notice] += 'Character Class levels were not destroyed.'
    end

    redirect_to :action => 'list'
  end

  def first_level
    @stat = CClassLevel.new(params[:stat])
    @stat.c_class_id = params[:id]
    @stat.level = 0
    @stat.min_xp = 0
  end

  def post_first_level
    #create the first level.
    @stat = CClassLevel.new(params[:stat])
    
    if @stat.validate
      session[:stat] = CClassLevel.new(params[:stat])
      session[:base_level] = CClassLevel.new(params[:stat])
      redirect_to :action => 'gen_levels', :pres => params[:pres]
    else
      render :action => 'first_level'
    end
  end

  def edit_first_level
    @stat = CClassLevel.find_by(c_class_id: params[:id], level: 0 )
    if @stat.nil?
      redirect_to :action => 'first_level',:id => params[:id]
    else
      render :action => 'first_level'
    end
  end

  def post_edit_first_level
    #edit  the first level.
    @stat = CClassLevel.new(params[:stat])
    
    if @stat.validate
      session[:stat] = CClassLevel.new(params[:stat])
      session[:base_level] = CClassLevel.new(params[:stat])
      redirect_to :action => 'gen_levels', :pres => params[:pres]
    else
      render :action => 'first_level'
    end
  end

  def gen_levels
    @numup = 0
    @nummade = 0

    if params[:add].nil?
      @bob=Array.new(75)
      @cumsum = CClassLevel.new
      @base = session[:base_level]

      if params[:pres].nil?
        #first, kill off all the levels for this class polluting the DB
        @cleanup = CClassLevel.where(c_class_id: session[:base_level][:c_class_id])
        clear_cleanup
      end

      @older_xp = 0
      @last_xp = 0
    else
      #if this is the case, then were just are adding levels, and nothing changing
      #redirect to first_level if there are none
      @lvls = CClassLevel.where(c_class_id: params[:id]).count
      if @lvls == 0
        redirect_to :action => 'first_level', :id => params[:id]
        return
      end

      @bob=Array.new(params[:add].to_i)
      @cumsum =  CClassLevel.find_by(c_class_id: params[:id], level: @lvls-1)
      @base = CClassLevel.find_by(c_class_id: params[:id], level: @lvls-1)
      
      @older = CClassLevel.find_by(c_class_id: params[:id], level: @lvls-2)
      if @older
        @older_xp = @older.min_xp
      else
        @older_xp = 0
      end
      
      @base.level += 1
      @last_xp = @base.min_xp
    end

    for b in @bob
      @c_class_level = CClassLevel.current_level(@base.c_class_id,@base.level)[0]

      if @c_class_level.nil?
        @c_class_level = CClassLevel.new
        @c_class_level.level = @base.level
        @c_class_level.c_class_id = @base.c_class_id
        @flag = nil
      else
        @flag = 'true'
      end

      print " " + @last_xp.inspect + " " + @older_xp.inspect + " " + (@last_xp + @older_xp).to_s
      
      get_stat_level_bonus
      inc_cumsum
      set_current_level_stats
      @c_class_level.min_xp = @last_xp + @older_xp

      #We'll check to see that the correct number saved at the end
      if @flag
        if @c_class_level.save
          @numup += 1
        end
        debuggery(@c_class_level.level.to_s + " :: " + @c_class_level.errors.size.to_s)
      else
        if @c_class_level.save
          @nummade += 1
        end
        debuggery(@c_class_level.level.to_s + " :: " + @c_class_level.errors.size.to_s)
      end

      #moving this to the end will keep level zero free, and elim the need
      #to save it again
      @c_class_level.min_xp = CClassLevel.calc_min_experience(@c_class_level)
      @older_xp += @last_xp
      @last_xp = @c_class_level.min_xp
      @base.level += 1
    end
    flash[:notice] = 'CClassLevels populated for the "' + @c_class_level.c_class.name + '" class! generated: ' + @nummade.to_s + '; updates: ' + @numup.to_s + '; current: ' + CClassLevel.where(c_class_id: @base.c_class_id).count.to_s + '; out of ' + @bob.size.to_s + ' rows.'
    redirect_to :action => 'list'
  end

protected
  
  def get_stat_level_bonus
    @c_class_level.dam = CClassLevel.mod_level_bonus(@c_class_level.level,@base.dam)
    @c_class_level.dfn = CClassLevel.mod_level_bonus(@c_class_level.level,@base.dfn)
    @c_class_level.dex = CClassLevel.mod_level_bonus(@c_class_level.level,@base.dex)
    @c_class_level.con = CClassLevel.mod_level_bonus(@c_class_level.level,@base.con)
    @c_class_level.int = CClassLevel.mod_level_bonus(@c_class_level.level,@base.int)
    @c_class_level.mag = CClassLevel.mod_level_bonus(@c_class_level.level,@base.mag)
    @c_class_level.str = CClassLevel.mod_level_bonus(@c_class_level.level,@base.str)
    @c_class_level.freepts = @base.freepts * @c_class_level.level.to_s.size
  end

  def inc_cumsum
    @cumsum.dam += @c_class_level.dam
    @cumsum.dfn += @c_class_level.dfn
    @cumsum.dex += @c_class_level.dex
    @cumsum.con += @c_class_level.con
    @cumsum.int += @c_class_level.int
    @cumsum.mag += @c_class_level.mag
    @cumsum.str += @c_class_level.str
    @cumsum.freepts = @c_class_level.freepts
  end

  def set_current_level_stats
    @c_class_level.dam = @cumsum.dam
    @c_class_level.dfn = @cumsum.dfn
    @c_class_level.dex = @cumsum.dex
    @c_class_level.con = @cumsum.con
    @c_class_level.int = @cumsum.int
    @c_class_level.mag = @cumsum.mag
    @c_class_level.str = @cumsum.str
    @c_class_level.freepts = @cumsum.freepts
  end
 
  def clear_cleanup
    for junk in @cleanup
      junk.destroy
    end
  end
end
