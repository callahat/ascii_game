class Management::LevelsController < ManagementController
	before_filter :setup_kingdom_vars
	before_filter :setup_level_variable, :except => :index

	layout 'main'

	def index
		@levels = Level.get_page(params[:page], @kingdom.id)
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :create, :update ], :redirect_to => { :action => :index }

	def show
		@level = @kingdom.levels.find(:first, :conditions => ['id = ?', params[:id] ] )
	end

	def new
		@level = Level.new
		
		@lowest = @kingdom.levels.first.level - 1
		@highest = @kingdom.levels.last.level + 1
	end
	
	def create
		@level = Level.new(params[:level].merge(:kingdom_id => @kingdom.id))
		
		#make sure king can afford
		@cost = (@level.level.abs.power! 3) * @level.maxx.to_i * @level.maxy.to_i
		session[:kingdom][:gold] = Kingdom.find(session[:kingdom][:id]).gold
		
		unless TxWrapper.take(@kingdom, :gold, @cost)
			flash[:notice] = 'It would cost ' + @cost.to_s + ' gold, which the kingdom doesn\'t have.'
			redirect_to mgmt_levels_new_url()
		else
			if @level.save
				@emtpy_feature = Feature.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', "\nEmpty", -1, -1])
				LevelMap.gen_level_map_squares(@level, @emtpy_feature)
				flash[:notice] = 'Level ' + @level.level.to_s + ' was successfully created.'
				flash[:notice] += '<br/>' + @savecount.to_s + ' map squares out of ' + (@level.maxy * @level.maxx).to_s + ' created.'
				redirect_to mgmt_levels_url()
			else
				@lowest = session[:kingdom].levels.first.level - 1
				@highest = session[:kingdom].levels.last.level + 1
				render :action => 'new'
			end
		end
	end
	
	def edit
		@gold = @kingdom.gold
		@features = @kingdom.pref_list_features.collect{|f| f.feature}
	end
	
	
	def update
		edit
		calc_cost
		
		unless TxWrapper.take(@kingdom, :gold, @cost)
			flash[:notice] = 'There is not enough gold in your coffers to pay for the construction.<br/>'
			flash[:notice] += 'Available amount : ' + session[:kingdom][:gold].to_s + ' ; Total build cost : ' + @cost.to_s
			redirect_to mgmt_levels_edit_url(:id => @level.id)
		else
			0.upto(@level.maxy-1){|y|
				0.upto(@level.maxx-1){|x|
					@temp = @level.level_maps.find(:all, :conditions => ['ypos = ? and xpos = ?', y, x]).last

					if (@temp.feature_id.to_i != params[:map][y.to_s][x.to_s].to_i) &&
						 (@temp.feature.nil? || @temp.feature.name[0..0] != "\n")
						#if this is has storefronts, get rid of the previous store vacancies.
						if @temp.feature
							if @temp.feature.store_front_size.to_i > 0
								@temp.kingdom_empty_shops.each{ |store| store.destroy }
								@temp.feature.feature_events.each{ |fe|
									next unless fe.event.class == EventNpc
									fe.event.npc.update_attribute(:is_hired, false)
									fe.event.destroy
									fe.destroy }
							end
							TxWrapper.take(@kingdom, :housing_cap, @temp.feature.num_occupants.to_i)
						end
					
						@temp = LevelMap.create(
											:level_id => @level.id,
											:xpos => x,
											:ypos => y,
											:feature_id => params[:map][y.to_s][x.to_s])
						
						if @temp.feature
							TxWrapper.give(@kingdom, :housing_cap, @temp.feature.num_occupants)
							@temp.feature.store_front_size.times{
								@kingdom.kingdom_empty_shops.create(:level_map_id => @temp.id) }
						end
					end
				}
			}
			flash[:notice] = 'Level was successfully updated. Cost was : ' + @cost.to_s
			redirect_to mgmt_levels_show_url(:id => @level.id)
		end
	end
	
protected
	def calc_cost
		@cost = 0
		return if params.nil? || params[:map].nil?

		0.upto(@level.maxy-1){|y|
			0.upto(@level.maxx-1){|x|
				@old = @level.level_maps.find(:all, :conditions => ['ypos = ? and xpos = ?', y, x]).last.feature
				new = ( params[:map][y.to_s][x.to_s] && params[:map][y.to_s][x.to_s] != "" ?
									Feature.find(params[:map][y.to_s][x.to_s]) : nil )
				#print "#{@new} - #{@old} = #{params[:map][@y.to_s][@x.to_s]}\n"
				@cost += (@new ? @new.cost : 0) - ( (@old ? @old.cost : 0) / 5) if @old != @new
			}
		}
	end
	
	def setup_level_variable
		redirect_to mgmt_levels_url() and return() unless @level = @kingdom.levels.find(:first, :conditions => ['id = ?', params[:id] ])
	end
end
