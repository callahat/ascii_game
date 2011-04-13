class ForumController < ApplicationController
	before_filter :authenticate, :except => ['index', 'forum_router', 'boards', 'view_thred', 'threds']
	before_filter :filter_before_new_forum_node, :only => [ :new_thred, :create_thred, :create_post, :update_post, :delete ]
	before_filter :filter_before_delete_forum_node, :only => [ :delete_post ]
	
	before_filter :filter_min_mod_level, :only => [ :banhammer, :hammer_strike, :promote_mod, :do_promote ]
	before_filter :filter_low_mod_level, :only => [ :toggle_lock ]
	before_filter :filter_mid_mod_level, :only => [	:toggle_hidden, :toggle_mods_only ]
	before_filter :filter_hi_mod_level, :only => [ :toggle_delete ]
	
	before_filter :filter_mod_level_for_promotion, :only => [ :banhammer, :hammer_strike, :promote_mod, :do_promote ]
	layout 'main'

	def index
	p "HIT INDEX"
		boards
		render :action => 'boards'
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :index }

	def forum_router
		flash.keep(:notice)
		if params[:post_id]
			session[:post_id] = params[:post_id]
		elsif params[:thred_id]
			session[:parent_node] = params[:thred_id]
			session[:thred_id] = params[:thred_id]
		elsif params[:board_id]
			session[:board_id] = params[:board_id]
		end
		
		if session[:post_id]
			redirect_to :action => 'view_thred'
		elsif session[:thred_id]
			redirect_to :action => 'view_thred'
		elsif session[:board_id]
			redirect_to :action => 'threds'
		else
			redirect_to :action => 'boards'
		end
	end

	def boards
		session[:board_id] = nil #no longer looking at a particular board
		@more_conds = node_flags(session[:player])
		@boards = ForumNode.get_page(params[:page], @more_conds)
	end

	def new_board
		@board = ForumNode.new
	end

	def create_board
		@board = ForumNode.new(params[:board])
		@board.player_id = session[:player][:id]
		@board.datetime = Time.now
		#@board.forum_node_id = nil	#this goes without saying.
		
		if @board.save
			flash[:notice] = "Board created"
			redirect_to :action => 'boards'
		else
			flash[:notice] = "Failed to create board"
			render :action => 'new_board'
		end
	end
	
	def edit_board
		@board = ForumNode.find(params[:board_id])
	end
	
	def update_board
		@board = ForumNode.find(params[:board_id])
		
		#no editing the board name if mod_level too low, this also allows duplicate names
		if session[:player].mod_level == 9
			@board.name = params[:board][:name]
		end
		
		@board.text = params[:board][:text]
		
		if @board.save
			flash[:notice] = "Description updated"
			redirect_to :action => 'forum_router'
		else
			flash[:notice] = "Failed to update descritpion"
			render :action => 'edit_board',:board_id => @board.id
		end
	end
	
	def threds
		if session[:board_id].nil?
			redirect_to :action => 'boards'
			return
		end
		session[:thred_id] = nil	#no longer looking at a particular thread now
		session[:post_id] = nil
		
		@board = ForumNode.find(:first, :conditions => ['id = ?', session[:board_id]])
		session[:parent_node] = session[:board_id]
		session[:before_node_add] = "threds"
		
		@more_conds = node_flags(session[:player])
		@threds = ForumNode.get_page(params[:page], @more_conds, @board.id)
	end
	
	def view_thred
		if session[:post_id]
			@post = ForumNode.find(:first, :conditions => ['id = ?', session[:post_id]])
		end
		if session[:thred_id].nil?
			redirect_to :action => 'threds'
			return
		end
		
		@thred = ForumNode.find(session[:thred_id])
		
		@more_conds = node_flags(session[:player])
		
		@posts = ForumNode.get_page(params[:page], @more_conds, @thred.id)
	end
	
	def new_thred
		@thred = ForumNode.new
		@board = ForumNode.find(session[:board_id])
	end
	
	def create_thred
		@thred = ForumNode.new(params[:thred])
		@board = ForumNode.find(session[:board_id])
		
		@thred.forum_node_id = session[:board_id]
		@thred.datetime = Time.now.to_date
		@thred.player_id = session[:player][:id]
		@thred.elders = @board.elders + 1
		
		if !@thred.save
			render :action => 'new_thred'
		else
			flash[:notice] = 'Thred created sucessfully'
			redirect_to :action => 'forum_router',:thred_id => @thred.id
		end
	end

	def edit_thred
		@thred = ForumNode.find(params[:thred_id])
		@board = ForumNode.find(session[:board_id])
	end

	def update_thred
		@thred = ForumNode.find(params[:thred_id])
		@board = ForumNode.find(session[:board_id])
		
		params[:thred][:player_id] = @thred.player_id
		params[:thred][:datetime] = @thred.datetime
		
		#no editing the board name if mod_level too low
		if session[:player].mod_level < 6
			params[:thred][:name] = @thred.name
		end
		
		if @thred.update_attributes(params[:thred])
			flash[:notice] = "Description updated"
			redirect_to :action => 'forum_router'
		else
			flash[:notice] = "Failed to update descritpion"
			render :action => 'edit_thred',:thred_id => @thred.id
		end
	end

	def leaderboard
	
	end

	def cancel_edit
		session[:post_id] = nil
		redirect_to :action => 'forum_router'
	end

	def create_post
		@post = ForumNode.new(params[:post])
		if @post.text == ""
			flash[:notice] = "Can't post nothing"
			redirect_to :action => 'forum_router'
			return
		end
		@thred = ForumNode.find(session[:thred_id])
		
		@post.forum_node_id = session[:thred_id]
		@post.datetime = Time.now
		@post.player_id = session[:player][:id]
		@post.name = session[:player][:handle] + ',' + Time.now.to_s + ',' + session[:player].posts.size.to_s
		@post.elders = ForumNode.find(session[:thred_id]).elders + 1
		if session[:player].mod_level > 0 && params[:mods_only]	== "1"
			@post.is_mods_only = true
		else
			@post.is_mods_only = false
		end
		
		if !@post.save
			view_thred
			render :action => 'view_thred'
		else
			flash[:notice] = 'Posted!'
			params[:post] = nil #destroy the parameters to prevent refreshes from adding multiple posts, works in firefox at least.
			redirect_to :action => 'forum_router'
		end
	end

	def update_post
		@post = ForumNode.find(params[:post_id])
		@post.text = params[:post][:text]
		@post.edit_notices = @post.edit_notices.to_s + '<br/>Edited by ' + session[:player][:handle] + ' at ' + Time.now.strftime("%m-%d-%Y %I:%M.%S %p")
		if session[:player].mod_level > 0 && params[:mods_only]	== "1"
			@post.is_mods_only = true
		else
			@post.is_mods_only = false
		end

		if @post.valid?
			@post.save
			session[:post_id] = nil
			flash[:notice] = "Updated post!"
			redirect_to :action => 'forum_router'
		else
			view_thred
			flash[:notice] = "Failed to update post"
			render :action => 'forum_router'
		end
	end

	def delete_post
		@post = ForumNode.find(params[:post_id])
		@post.is_deleted = true
		@post.edit_notices = @post.edit_notices.to_s + '<br/>Deleted by ' + session[:player][:handle] + ' at ' + Time.now.strftime("%m-%d-%Y %I:%M.%S %p")
		if @post.save
			flash[:notice] = "Post deleted"
		end
		
		redirect_to :action => 'forum_router'
	end

	#moderator tools
	def banhammer	#do i still even make use of this one?
		@forum_restriction = ForumRestriction.new
		@player = Player.find(params[:player_id])
		@restrictions = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'restrictions'])
	end
	
	def hammer_strike
		@forum_restriction = ForumRestriction.new(params[:forum_restriction])
		@player = Player.find(params[:player_id])
		@restrictions = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'restrictions'])
		@forum_restriction.player_id = @player.id
		@forum_restriction.given_by = session[:player][:id]
		
		if session[:player].mod_level < 9 &&
			 (params[:forum_restriction][:expires].nil? || params[:forum_restriction][:expires] == "" ||
			 params[:forum_restriction][:expires].to_i > session[:player].mod_level*2)
			flash[:notice] = "You cannot ban someone that long"
			render :action => 'banhammer'
			return
		elsif params[:forum_restriction][:expires].nil? || params[:forum_restriction][:expires] == ""
			@forum_restriction.expires = nil
		else
			@forum_restriction.expires = Time.now + [params[:forum_restriction][:expires].to_i.day,27.years].min
		end
		
		if @forum_restriction.save
			flash[:notice] = "Restriction saved"
			redirect_to :action => 'forum_router'
		else
			flash[:notice] = "Error in creating restriction"
			render :action => 'banhammer'
		end
	end
	
	def kill_ban
		@ban = ForumRestriction.find(:first, :conditions => ['id = ?', params[:ban_id]])
		if @ban.nil?
			#nothing
		elsif @ban.given_by != session[:player][:id] && @ban.giver.mod_level > session[:player].mod_level
			flash[:notice] = "Cannot remove a restriction placed by someone with a higher mod level than yourself."
		else
			if @ban.destroy
				flash[:notice] = "Removed restriction"
			else
				flash[:notice] = "Faield to remove restriction"
			end
		end
		params[:ban_id] = nil #make it safe for refreshes
		redirect_to :action => 'banhammer', :player_id => @ban.player_id
	end
	
	def promote_mod
		@player = Player.find(params[:player_id])
	end
	
	def do_promote
		@player = Player.find(params[:player_id])
		if session[:player].mod_level > params[:player][:mod_level].to_i && params[:player][:mod_level].to_i > -1
		Player.transaction do
				@player.lock!
				@player.mod_level = params[:player][:mod_level].to_i
				flash[:notice] = "Updated player mod level"
		@player.save!
		end
		redirect_to :action => 'forum_router'
		else
			flash[:notice] = "mod level must be between 0 and " + (session[:player].mod_level - 1).to_s
			render :action => 'promote_mod'
		end
	end
	
	def toggle_locked
		toggle_filter(ForumNode.find(:first, :conditions => ['id = ?', params[:forum_node_id]]), :is_locked)
		redirect_to :action => 'forum_router'
	end
	
	def toggle_hidden
		toggle_filter(ForumNode.find(:first, :conditions => ['id = ?', params[:forum_node_id]]), :is_hidden)
		redirect_to :action => 'forum_router'
	end
	
	def toggle_deleted
		toggle_filter(ForumNode.find(:first, :conditions => ['id = ?', params[:forum_node_id]]), :is_deleted)
		redirect_to :action => 'forum_router'
	end
	
	def toggle_mods_only
		toggle_filter(ForumNode.find(:first, :conditions => ['id = ?', params[:forum_node_id]]), :is_mods_only)
		redirect_to :action => 'forum_router'
	end
	
	def show_restrictions
	end

protected
	def node_flags(player)	#builds conditions for forum, what a player can see based on mod level
		
		if player.nil?
			return ' AND is_deleted = false AND is_hidden = false AND is_mods_only = false'
		elsif player.mod_level == 9	#sees all
			return ''
		elsif player.mod_level > 2
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
		if session[:player].mod_level > level
			return true
		else
			redirect_to :action => 'forum_router'
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
		if params[:forum_node_id]
			return true
		else
			return false
		end
	end

	def filter_mod_level_for_promotion
		@player = Player.find(:first, :conditions => ['id = ?', params[:player_id]])
		if @player.nil?
			redirect_to :action => 'view_thred'
			return false
		elsif session[:player].mod_level > @player.mod_level+1
			return true
		else
			#do not allow promotion
			flash[:notice] = "You cannot do that; " + @player.handle + " has a higher mod level"
			redirect_to :action => 'view_thred'
			return false
		end
	end

	#replan all this. figuer out filters for:
	#Before delete node
	#node unlocked, (node is locked if a parent is locked)
	#node viewable, (node is hidden if parent is hidden)
	#node deleted, (node is deleted if parent is deleted)

	def filter_before_new_forum_node
		@parent_forum_node = ForumNode.find(:first, :conditions => ['id = ?', session[:parent_node]])
	
		
		p session[:player].player_characters.find(:first, :conditions => 'level > 9')
		p session[:player].mod_level
		p @parent_forum_node.elders
	
	
		if session[:player].mod_level < 9 && ((@parent_forum_node.elders > 0 && ForumRestriction.no_posting(session[:player])) ||
																					(ForumRestriction.no_threding(session[:player])) ||
																					@parent_forum_node.parent_forum_node(:is_deleted) ||
																					@parent_forum_node.parent_forum_node(:is_hidden) || 
																					@parent_forum_node.parent_forum_node(:is_locked) || 
																					(@parent_forum_node.parent_forum_node(:is_mods_only) && session[:player].mod_level < 1))
			redirect_to :action => 'forum_router'
			p 'redireting to forum_router'
			return false
		else
			return true
		end
	end

	def filter_before_view_forum_node
		@parent_forum_node = ForumNode.find(:first, :conditions => ['id = ?', session[:parent_node]])
		if session[:player].mod_level < 7 && (ForumRestriction.no_viewing(session[:player])
																					@parent_forum_node.parent_forum_node(:is_deleted) ||
																					(session[:player].mod_level < 5 && @parent_forum_node.parent_forum_node(:is_hidden)) || 
																					(session[:player].mod_level < 1 && @parent_forum_node.parent_forum_node(:is_mods_only)))
			redirect_to :action => 'forum_router'
			return false
		else
			return true
		end
	end


	def filter_before_forum_node_delete
	end


	def filter_before_delete_forum_node
		@post = ForumNode.find(:first, :conditions => ['id = ?', params[:post_id]])
		if @post.player_id != session[:player][:id] && session[:player][:mod_level] < 8
			if session[:player].mod_level < 1
				flash[:notice] = "You cannot delete a post that is not yours"
			else
				flash[:notice] = "You may not edit delete a post; your mod level is insufficient"
			end
			redirect_to :action => 'forum_router', :thred_id => session[:thred_id]
			return false
		else
			return true
		end
	end
end
