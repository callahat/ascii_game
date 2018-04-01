class Admin::HealingSpellsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  layout 'admin'

  def index
    @healing_spells = HealingSpell.get_page(params[:page])
  end

  def show
    @healing_spell = HealingSpell.find(params[:id])
  end

  def new
    @healing_spell = HealingSpell.new
  end

  def create
    @healing_spell = HealingSpell.new(params[:healing_spell])
    if @healing_spell.save
      flash[:notice] = 'Healing Spell was successfully created.'
      redirect_to admin_healing_spell_path(@healing_spell)
    else
      render :action => 'new'
    end
  end

  def edit
    @healing_spell = HealingSpell.find(params[:id])
  end

  def update
    @healing_spell = HealingSpell.find(params[:id])
    if @healing_spell.update_attributes(params[:healing_spell])
      flash[:notice] = 'Healing Spell was successfully updated.'
      redirect_to admin_healing_spell_path(@healing_spell)
    else
      render admin_healing_spells_path
    end
  end

  def destroy
    HealingSpell.find(params[:id]).destroy
    redirect_to admin_healing_spells_path
  end
end
