class Admin::RacesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @races = Race.get_page(params[:pages])
  end

  def show
    @race = Race.find(params[:id])
  end

  def new
    @race = Race.new
    @race.build_level_zero
    @race.build_image
    20.times { @race.race_equip_locs.build }
    @equip_locs = SpecialCode.get_codes_and_text('equip_loc')
  end

  def create
    @race = Race.new(params[:race])
    @race.image.name = 'DEFAULT ' + @race.name + ' IMAGE'
    @race.image.player_id = session[:player].id
    @race.image.kingdom_id = Kingdom.find_by(name: 'SystemGeneratd').id

    if @race.save
      flash[:notice] = 'Race was successfully created.'
      redirect_to admin_race_path(@race)
    else
      (20 - @race.race_equip_locs.count).times { @race.race_equip_locs.build }
      @equip_locs = SpecialCode.get_codes_and_text('equip_loc')
      render :action => 'new'
    end
  end

  def edit
    @race = Race.find(params[:id])
    @equip_locs = SpecialCode.get_codes_and_text('equip_loc')
    (20 - @race.race_equip_locs.count).times { @race.race_equip_locs.build }
  end

  def update
    @race = Race.find(params[:id])

    if @race.update_attributes(params[:race])
      flash[:notice] = "Race updated"
      redirect_to admin_race_path(@race)
    else
      @equip_locs = SpecialCode.get_codes_and_text('equip_loc')
      (20 - @race.race_equip_locs.count).times { @race.race_equip_locs.build }
      render :action => 'edit'
    end
  end

  def destroy
    @race = Race.find(params[:id])

    if @race.destroy
      flash[:notice] = 'Race destroyed.'
    else
      flash[:notice] = 'Race was not completely destroyed.'
    end

    redirect_to admin_races_path
  end
end
