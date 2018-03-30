class Admin::AttackSpellsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @attack_spells = AttackSpell.get_page(params[:page])
  end

  def show
    @attack_spell = AttackSpell.find(params[:id])
  end

  def new
    @attack_spell = AttackSpell.new
  end

  def create
    @attack_spell = AttackSpell.new(params[:attack_spell])
    if @attack_spell.save
      flash[:notice] = 'AttackSpell was successfully created.'
      redirect_to admin_attack_spell_path(@attack_spell)
    else
      render :action => 'new'
    end
  end

  def edit
    @attack_spell = AttackSpell.find(params[:id])
  end

  def update
    @attack_spell = AttackSpell.find(params[:id])
    if @attack_spell.update_attributes(params[:attack_spell])
      flash[:notice] = "#{@attack_spell.name} was successfully updated."
      redirect_to admin_attack_spell_path(@attack_spell)
    else
      render :action => 'edit'
    end
  end

  def destroy
    AttackSpell.find(params[:id]).destroy
    redirect_to admin_attack_spells_path
  end
end
