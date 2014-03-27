class Management::KingdomItemsController < ApplicationController
	before_filter :setup_pc_vars
	before_filter :king_filter
	before_filter :char_is_king
	
	layout 'main'

	def index
		list
		render :action => 'list'
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :do_store, :do_take ],
#				 :redirect_to => { :action => :list }

	def list
		@kingdom_items = KingdomItem.get_page(params[:page], session[:kingdom][:id] )
	end

	def list_inventory
		@player_character_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
	end
	
	def store
		@player_character_item = PlayerCharacterItem.find(params[:id])
	end

	def do_store
		@item = Item.find(params[:item_id])
		quant = ( params[:player_character_item] ? params[:player_character_item][:quantity].to_i : 0 )
		
		if quant <= 0
			flash[:notice] = 'Number to remove must be positive'
			redirect_to :action => 'store', :id => params[:id]
		elsif PlayerCharacterItem.update_inventory(@pc.id,@item.id,-1 * quant) &&
					KingdomItem.update_inventory(session[:kingdom].id,@item.id,1 * quant)
			flash[:notice] = quant.to_s + ' ' + @item.name.pluralize + ' moved from the storerooms to your inventory.'
			redirect_to :action => 'list_inventory'
		else
			flash[:notice] = 'You cannot store more items than you have in the character\'s inventory.'
			redirect_to :action => 'store', :id => params[:id]
		end
	end

	def remove
		@kingdom_item = KingdomItem.find(params[:id])
	end

	def do_take
		@item = Item.find(params[:item_id])
		quant = ( params[:kingdom_item] ? params[:kingdom_item][:quantity].to_i : 0 )
	
		if quant <= 0
			flash[:notice] = 'Number to remove must be positive'
			redirect_to :action => 'remove', :id => params[:id]
		elsif KingdomItem.update_inventory(session[:kingdom].id,@item.id,-1 * quant.to_i) &&
					PlayerCharacterItem.update_inventory(@pc.id,@item.id,1 * quant)
			flash[:notice] = quant.to_s + ' ' + @item.name.pluralize + ' moved from the storerooms to your inventory.'
			redirect_to :action => 'list'
		else
			flash[:notice] = 'You cannot remove more items than exist in the kingdom.'
			redirect_to :action => 'remove', :id => params[:id]
		end
	end
end
