class Admin::ItemsController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		list
		render :action => 'list'
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :list }

	def list
		@items = Item.get_page(params[:page])
	end

	def show
		@item = Item.find(params[:id])
	end

	def new
		@item = Item.new
		@rbts = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'race_body_type'])
		@base_items = BaseItem.find(:all)
		@eqs = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'equip_loc'])
		@c_classes = CClass.find(:all)
		@races = Race.find(:all)
	end

	def create
		@item = Item.new(params[:item])
		@rbts = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'race_body_type'])
		@base_items = BaseItem.find(:all)
		@eqs = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'equip_loc'])
		@c_classes = CClass.find(:all)
		@races = Race.find(:all)
		if @item.save
			flash[:notice] = 'Item was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@item = Item.find(params[:id])
		@rbts = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'race_body_type'])
		@base_items = BaseItem.find(:all)
		@eqs = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'equip_loc'])
		@c_classes = CClass.find(:all)
		@races = Race.find(:all)
	end

	def update
		@item = Item.find(params[:id])
		@rbts = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'race_body_type'])
		@base_items = BaseItem.find(:all)
		@eqs = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'equip_loc'])
		@c_classes = CClass.find(:all)
		@races = Race.find(:all)
		if @item.update_attributes(params[:item])
			flash[:notice] = 'Item was successfully updated.'
			redirect_to :action => 'show', :id => @item
		else
			render :action => 'edit'
		end
	end

	def destroy
		#Add a check to make sure this item is not referenced anywhere before
		#it is destroyed.
		Item.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
