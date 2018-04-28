class Admin::RacesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_race, only: [:show,:edit,:update,:destroy]

  layout 'admin'

  def index
    @races = Race.get_page(params[:pages]).includes(:level_zero)
  end

  def show
  end

  def new
    @race = Race.new
    @race.build_level_zero
    @race.build_image
    prep_equip_locs
  end

  def create
    @race = Race.new(race_params)
    @race.image.name = 'DEFAULT ' + @race.name + ' IMAGE'
    @race.image.player_id = current_player.id
    @race.image.kingdom_id = Kingdom.find_by(name: 'SystemGeneratd').id

    if @race.save
      flash[:notice] = 'Race was successfully created.'
      redirect_to admin_race_path(@race)
    else
      prep_equip_locs
      render :action => 'new'
    end
  end

  def edit
    prep_equip_locs
  end

  def update
    @race.race_equip_locs.destroy_all
    if @race.update_attributes(race_params.tap{ |cp|
                                 cp[:image_attributes].merge!(
                                     id: @race.image_id,
                                     name: @race.image.name,
                                     player_id: @race.image.player_id,
                                     kingdom_id: @race.image.kingdom_id
                                 )})
      flash[:notice] = "Race updated"
      redirect_to admin_race_path(@race)
    else
      prep_equip_locs
      render :action => 'edit'
    end
  end

  def destroy
    if @race.destroy
      flash[:notice] = 'Race destroyed.'
    else
      flash[:notice] = 'Race was not completely destroyed.'
    end

    redirect_to admin_races_path
  end

  protected

  def race_params
    params.require(:race).permit(
        :name,
        :description,
        :kingdom_id,
        :race_body_type,
        :freepts,
        level_zero_attributes: [:str, :dex, :con, :int, :mag, :dfn, :dam],
        image_attributes: [:image_text, :public, :picture, :image_type],
        race_equip_locs_attributes: [:equip_loc]
    )
  end

  def set_race
    @race = Race.find(params[:id])
  end

  def prep_equip_locs
    @equip_locs = SpecialCode.get_codes_and_text('equip_loc')
    # set_locs = params.try(:[],:race).try(:[],:equip_locs)
    (20 - @race.race_equip_locs.size).times { @race.race_equip_locs.build }
  end
end
