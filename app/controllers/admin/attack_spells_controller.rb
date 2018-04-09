class Admin::AttackSpellsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_attack_spell, only: [:show, :edit, :update, :destroy]
  
  layout 'admin'

  def index
    @attack_spells = AttackSpell.get_page(params[:page])
  end

  def show
  end

  def new
    @attack_spell = AttackSpell.new
  end

  def create
    @attack_spell = AttackSpell.new(attack_spell_params)
    if @attack_spell.save
      flash[:notice] = 'AttackSpell was successfully created.'
      redirect_to admin_attack_spell_path(@attack_spell)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @attack_spell.update_attributes(attack_spell_params)
      flash[:notice] = "#{@attack_spell.name} was successfully updated."
      redirect_to admin_attack_spell_path(@attack_spell)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @attack_spell.destroy
    redirect_to admin_attack_spells_path
  end

  protected

  def attack_spell_params
    params.require(:attack_spell).permit(
        :name,
        :description,
        :min_level,
        :min_dam,
        :max_dam,
        :dam_from_mag,
        :dam_from_int,
        :mp_cost,
        :hp_cost,
        :splash)
  end

  def set_attack_spell
    @attack_spell = AttackSpell.find(params[:id])
  end
end
