class ForumController < ApplicationController
  before_filter :store_location, :only => [ :boards, :threds, :view_thred, :update_thred ]
  before_filter :authenticate, :except => ['index', 'forum_router', 'boards', 'view_thred', 'threds']

  before_filter :filter_min_mod_level, :only => [ :banhammer, :hammer_strike, :promote_mod, :do_promote ]
  before_filter :filter_low_mod_level, :only => [ :toggle_lock ]
  before_filter :filter_mid_mod_level, :only => [  :toggle_hidden, :toggle_mods_only ]
  before_filter :filter_hi_mod_level, :only => [ :toggle_delete ]
  
  before_filter :filter_mod_level_for_promotion, :only => [ :banhammer, :hammer_strike, :promote_mod, :do_promote ]
  
  before_filter :load_board, :only => [ :threds, :new_thred, :create_thred, :edit_thred, :update_thred]
  before_filter :load_thread, :only => [ :view_thred, :create_post, :delete_post, :update_post ]
#  before_filter :load_parent_post, :only => [ :create_post ]
  
  layout 'forum'
  
  def index
  p "HIT INDEX"
    boards
    render :action => 'boards'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],         :redirect_to => { :action => :index }

  def boards
    @more_conds = node_flags(session[:player])
    @boards = ForumNodeBoard.get_page(params[:page], @more_conds)
  end

  def new_board
    @board = ForumNodeBoard.new
  end

  def create_board
    @board = ForumNodeBoard.new(params[:board])
    @board.player_id = session[:player][:id]
    
    if @board.save
      flash[:notice] = "Board created"
      redirect_to :action => 'boards'
    else
      flash[:notice] = "Failed to create board"
      render :action => 'new_board'
    end
  end
  
  def edit_board
    @board = ForumNodeBoard.find(params[:forum_node_id])
  end
  
  def update_board
    edit_board
  
    #no editing the board name if mod_level too low, this also allows duplicate names
    @board.name = params[:board][:name] if session[:player].forum_attribute.mod_level == 9
    @board.text = params[:board][:text]
    
    if @board.save
      flash[:notice] = "Description updated"
      redirect_back_or_default(forums_url())
    else
      flash[:notice] = "Failed to update descritpion"
      render :action => 'edit_board',:board_id => @board.id
    end
  end
  
  def threds
    @more_conds = node_flags(session[:player])
    @threds = ForumNodeThread.get_page(params[:page], @more_conds, @board.id)
  end
  
  def view_thred
    unless @thred.can_be_viewed_by(session[:player])
      redirect_back_or_default(boards_url(:bname => @board.name))
      return
    end
  
    if params[:forum_node_id]
      @post = ForumNodePost.find( params[:forum_node_id] )
    end
    
    @user_mod_level = (session[:player] ? session[:player].forum_attribute.mod_level : -1)
    
    @more_conds = node_flags(session[:player])
    
    @posts = ForumNodePost.get_page(params[:page], @more_conds, @thred.id)
  end
  
  def new_thred
    @thred = ForumNodeThread.new
  end
  
  def create_thred
    @thred = @board.threads.new(params[:thred])
    @thred.player_id = session[:player][:id]
    
    if !@thred.save
      render :action => 'new_thred'
    else
      flash[:notice] = 'Thred created sucessfully'
      redirect_to(boards_url(:bname => @board.name))
    end
  end

  def edit_thred
    @thred = ForumNodeThread.find(params[:forum_node_id])
  end

  def update_thred
    #no editing the thread name if mod_level too low
    edit_thred
    
    @thred.name = params[:thred][:name] if session[:player].forum_attribute.mod_level > 9
    @thred.text = params[:thred][:text]
    
    if @thred.update_attributes(params[:thred])
      flash[:notice] = "Description updated"
      redirect_back_or_default(boards_url())
    else
      flash[:notice] = "Failed to update descritpion"
      render :action => 'edit_thred',:thred_id => @thred.id
    end
  end

  def leaderboard
  end

  def cancel_edit
    redirect_back_or_default(boards_url())
  end

  def create_post
    @post = @thred.posts.new(params[:post])
    @post.player_id = session[:player][:id]

    if !@post.save
      view_thred
      render :action => 'view_thred'
    else
      flash[:notice] = 'Posted!'
      params[:post] = nil #destroy the parameters to prevent refreshes from adding multiple posts, works in firefox at least.
      redirect_back_or_default(boards_url(:bname => @board.name))
    end
  end

  def update_post
    @post = ForumNodePost.find(params[:forum_node_id])

    if @post.update_post(session[:player][:handle],
                         params[:post][:text],
                         session[:player].forum_attribute.mod_level > 0 && params[:mods_only]  == "1")
       flash[:notice] = "Updated post!"
      redirect_back_or_default(boards_url(:bname => @board.name))
    else
      view_thred
      flash[:notice] = "Failed to update post"
      render :action => 'view_thred', :bname => @board.name, :tname => @thred.name
    end
  end

  def delete_post
    flash[:notice] = ForumNodePost.find(params[:forum_node_id]).mark_deleted(session[:player])
    redirect_back_or_default(boards_url(:bname => @board.name))
  end

  #moderator tools
  def banhammer  #do i still even make use of this one?
    @forum_restriction = ForumRestriction.new
    @player = Player.find(params[:player_id])
    @restrictions = SPEC_CODET['restrictions'].to_a
  end
  
  def hammer_strike
    @forum_restriction = ForumRestriction.new(params[:forum_restriction])
    @player = Player.find(params[:player_id])
    @restrictions = SPEC_CODET['restrictions'].to_a
    @forum_restriction.player_id = @player.id
    @forum_restriction.given_by = session[:player][:id]
        
    if @forum_restriction.save
      flash[:notice] = "Restriction saved"
      redirect_back_or_default(forums_url())
    else
      flash[:notice] = "Error in creating restriction"
      render :action => 'banhammer'
    end
  end
  
  def kill_ban
    @ban = ForumRestriction.find(params[:ban_id])
    (redirect_to(:back) && return) unless @ban
    res, msg = @ban.kill_ban(session[:player])
    flash[:notice] = msg    
    params[:ban_id] = nil #make it safe for refreshes
    redirect_to :action => 'banhammer', :player_id => @ban.player_id
  end
  
  def promote_mod
    @player = Player.find(params[:player_id])
  end
  
  def do_promote
    @player = Player.find(params[:player_id])
    if session[:player].forum_attribute.mod_level > params[:player][:mod_level].to_i && params[:player][:mod_level].to_i > -1
      Player.transaction do
        @player.lock!
        @player.forum_attribute.mod_level = params[:player][:mod_level].to_i
        flash[:notice] = "Updated player mod level"
      @player.save!
      end
      redirect_back_or_default(boards_url(:bname => @board.name))
    else
      flash[:notice] = "mod level must be between 0 and " + (session[:player].forum_attribute.mod_level - 1).to_s
      render :action => 'promote_mod'
    end
  end
  
  def toggle_locked
    toggle_filter(ForumNode.find(params[:forum_node_id]), :is_locked)
    redirect_to :back
  end
  
  def toggle_hidden
    toggle_filter(ForumNode.find(params[:forum_node_id]), :is_hidden)
    redirect_to :back
  end
  
  def toggle_deleted
    toggle_filter(ForumNode.find(params[:forum_node_id]), :is_deleted)
    redirect_to :back
  end
  
  def toggle_mods_only
    toggle_filter(ForumNode.find(params[:forum_node_id]), :is_mods_only)
    redirect_to :back
  end
  
  def show_restrictions
  end

protected
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.url unless params[:forum_node_id]
  end
  
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end
  
  def load_board
    @board = ForumNodeBoard.find_by(name: params[:bname])
    (redirect_to(forums_url) && return) if @board.nil?
  end
  
  def load_thread
    load_board
    @thred = ForumNodeThread.find_by(name: params[:tname], forum_node_id: @board.id)
    redirect_to(boards_url(:bname => @board.name)) && return  if @thred.nil?
  end
  
  def node_flags(player)  #builds conditions for forum, what a player can see based on mod level
    if player.nil?
      return ' AND is_deleted = false AND is_hidden = false AND is_mods_only = false'
    elsif player.forum_attribute.mod_level == 9  #sees all
      return ''
    elsif player.forum_attribute.mod_level > 2
      return ' AND is_deleted = false'
    else
      if !player.forum_restrictions.exists?(:restriction => SpecialCode.get_code('restrictions','no_viewing'))
        return ' AND is_deleted = false AND is_hidden = false AND is_mods_only = false'
      else
        return ' AND false'
      end
    end
  end

  def toggle_filter(what, filter)
    what[filter] = !what[filter]
    what.save
  end

  def filter_mod(level)
    if session[:player].forum_attribute.mod_level > level
      return true
    else
      begin
        redirect_to :back
      rescue
      end
      return false
    end
  end

  def filter_min_mod_level
    return filter_mod(0)
  end

  def filter_low_mod_level
    return filter_mod(2)
  end

  def filter_mid_mod_level
    return filter_mod(4)
  end

  def filter_hi_mod_level
    return filter_mod(6)
  end

  def filter_forum_node_param
    !params[:forum_node_id].nil?
  end

  def filter_mod_level_for_promotion
    @player = Player.find(params[:player_id])
    if @player.nil?
      redirect_to :action => 'view_thred'
      return false
    elsif session[:player].forum_attribute.mod_level > @player.forum_attribute.mod_level+1
      return true
    else
      #do not allow promotion
      flash[:notice] = "You cannot do that; " + @player.handle + " has a higher mod level"
      redirect_to :action => 'view_thred'
      return false
    end
  end
end
