class Admin::HealingSpellsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_healing_spell, only: [:show,:edit,:update,:destroy]

  layout 'admin'

  def index
    @healing_spells = HealingSpell.get_page(params[:page]).includes(:disease)
  end

  def show
  end

  def new
    @healing_spell = HealingSpell.new
  end

  def create
    @healing_spell = HealingSpell.new(healing_spell_params)
    if @healing_spell.save
      flash[:notice] = 'Healing Spell was successfully created.'
      redirect_to admin_healing_spell_path(@healing_spell)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @healing_spell.update_attributes(healing_spell_params)
      flash[:notice] = 'Healing Spell was successfully updated.'
      redirect_to admin_healing_spell_path(@healing_spell)
    else
      render admin_healing_spells_path
    end
  end

  def destroy
    @healing_spell.destroy
    redirect_to admin_healing_spells_path
  end

  protected

  def healing_spell_params
    params.require(:healing_spell).permit(
        :name,:description,:min_level,:min_heal,:max_heal,:disease_id,:mp_cost,:cast_on_others)
  end

  def set_healing_spell
    @healing_spell = HealingSpell.find(params[:id])
  end
end
