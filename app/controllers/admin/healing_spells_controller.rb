class Admin::HealingSpellsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  layout 'admin'

  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],         :redirect_to => { :action => :list }

  def list
    @healing_spells = HealingSpell.get_page(params[:page])
  end

  def show
    @healing_spell = HealingSpell.find(params[:id])
  end

  def new
    @healing_spell = HealingSpell.new
    @diseases = Disease.find(:all)
  end

  def create
    @healing_spell = HealingSpell.new(params[:healing_spell])
    @diseases = Disease.find(:all)
    if @healing_spell.save
      flash[:notice] = 'HealingSpell was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @healing_spell = HealingSpell.find(params[:id])
    @diseases = Disease.find(:all)
  end

  def update
    @healing_spell = HealingSpell.find(params[:id])
    @diseases = Disease.find(:all)
    if @healing_spell.update_attributes(params[:healing_spell])
      flash[:notice] = 'HealingSpell was successfully updated.'
      redirect_to :action => 'show', :id => @healing_spell
    else
      render :action => 'edit'
    end
  end

  def destroy
    HealingSpell.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
