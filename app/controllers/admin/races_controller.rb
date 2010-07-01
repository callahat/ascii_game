class Admin::RacesController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		list
		render :action => 'list'
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :list }

	def list
		@races = Race.get_page(params[:pages])
	end

	def new
		@race = Race.new
		@rls = Array.new(20,RaceEquipLoc.new)
		@equip_locs = SPEC_CODEC['equip_loc'].collect{|c,t| ColnumText.new(c, t) }
		@stat = StatRace.new
		@image = (params[:image].nil? || params[:image][:imag_text] == "" ? @race.image : Image.new(params[:image]) )
	end

	def create
		@race = Race.new(params[:race])
		@rls = params[:race_equip_loc].collect{|h| RaceEquipLoc.new(h[1]) }
		@equip_locs = SPEC_CODEC['equip_loc'].collect{|c,t| ColnumText.new(c, t) }
		@stat = StatRace.new(params[:stat])
		@image = Image.new(params[:image]) || @race.image
		@image.id = 0 if @race.image_id != 140
		@image.name = 'DEFAULT ' + @race.name + ' IMAGE'
		
		if @stat.valid_for_level_zero && @stat.save && (@race.stat_id = @stat.id) && @image.save && (@race.image_id = @image.id) && @race.save
			#if the stat and race save, its safe to create the equip locations
			@rls.each{|rl| next if rl.equip_loc.nil?
					RaceEquipLoc.create(:race_id => @race.id, :equip_loc => rl.equip_loc) }
			flash[:notice] = 'Race was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@race = Race.find(params[:id])
		@rls = @race.race_equip_locs
		@rls = [@rls, Array.new(20-@rls.size, RaceEquipLoc.new)]
		@rls.flatten!
		@image = @race.image
		@equip_locs = SPEC_CODEC['equip_loc'].collect{|c,t| ColnumText.new(c, t) }
		@stat = @race.level_zero
	end

	def update
		@race = Race.find(params[:id])
		@stat = @race.stat
		@equip_locs = SPEC_CODEC['equip_loc'].collect{|c,t| ColnumText.new(c, t) }
		@rls = params[:race_equip_loc].collect{|h| RaceEquipLoc.new(h[1]) }
		@image = @race.image
		if @race.image_id == Image.find_by_name("DEFAULT PC IMAGE").id
			@image = Image.create(@image.attributes)
			@image.name = "DEFAULT " + @race.name + " IMAGE"
			params[:race][:image_id] = @image.id
		end
		@image.update_image(params[:image][:image_text]) unless params[:image][:image_text] == ""
		
		if @stat.valid_for_level_zero & @stat.update_attributes(params[:stat]) & @race.update_attributes(params[:race]) & @image.save
			@race.race_equip_locs.destroy_all
			@rls.each{|rl| next if rl.equip_loc.nil?
					RaceEquipLoc.create(:race_id => @race.id, :equip_loc => rl.equip_loc) }
			flash[:notice] = "Race updated"
			redirect_to :action => 'list'
		else
			render :action => 'edit'
		end
	end

	def destroy
		@race = Race.find(params[:id])

		if @race.level_zero.destroy && @race.race_equip_locs.destroy_all && @race.destroy
			flash[:notice] = 'Character Race destroyed. <br/>'
		else
			flash[:notice] = 'Character Race was not completely destroyed. <br/>'
		end

		redirect_to :action => 'list'
	end
end