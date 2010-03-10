class Management::ImagesController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	def index
		@images = Image.get_page(params[:page], session[:kingdom][:id] )
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :index }

	def show
		@image = Image.find(params[:id])
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
		@image = Image.new
		if session[:player][:admin]
			@types = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'image_type'])
		else
			@types = SpecialCode.find(:all, :conditions => ['spec_col_type = "image_type" and (text = ? or text = ?)','kingdom','creature'])
		end
		set_image_box_size
	end

	def create
		@image = Image.new(params[:image])
		@image.player_id = session[:player][:id]
		@image.kingdom_id = session[:kingdom][:id]
		
		#take care of cropping the image
		crop_ascii_image
		
		@image.image_text = params[:image][:image_text]
		
		if @image.save
			flash[:notice] = @image.name + ' was successfully created.'
			redirect_to :action => 'index'
		else
			new
			render :action => 'new'
		end
	end

	def edit
		@image = Image.find(params[:id])
		verify_image_owner
		set_image_box_size
		if session[:player][:admin]
			@types = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'image_type'])
		else
			@types = SpecialCode.find(:all, :conditions => ['spec_col_type = "image_type" and (text = ? or text = ?)','kingdom','creature'])
		end
	end

	def update
		@image = Image.find(params[:id])
		if !verify_image_owner
			redirect_to :action => 'index'
			return
		end
		
		#take care of cropping the image
		crop_ascii_image
		
		if @image.update_attributes(params[:image])
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
		if !@image.image_type.nil? &&(@image.image_type == SpecialCode.get_code('image_type','kingdom') || 
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
	
	def crop_ascii_image
		if @image.image_type == SpecialCode.get_code('image_type','kingdom') || 
			 @image.image_type == SpecialCode.get_code('image_type','world')
			resize_image(10,15)
		else
			resize_image(0,0)
		end
	end
end
