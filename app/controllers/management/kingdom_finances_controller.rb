class Management::KingdomFinancesController < ApplicationController
  before_filter :setup_pc_vars
  before_filter :king_filter

  layout 'main'

  def index
    show
    render :action => 'show'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :withdraw, :deposit, :adjust_tax ],
#         :redirect_to => { :action => :show }

  def show
    @cash = session[:kingdom].gold
    @tax_rate = session[:kingdom].tax_rate
  end

  def edit
    @cash = session[:kingdom].gold
    @tax = session[:kingdom].tax_rate
  end

  def withdraw
    @withdraw = params[:withdraw][0].to_i
    if TxWrapper.take(session[:kingdom], :gold, @withdraw)
      flash[:notice] = 'Amount to withdrawl cannot exceed the gold in the coffers.'
    else
      TxWrapper.give(@pc, :gold, @withdraw)
      flash[:notice] = 'Withdrawl successful.'
    end
    redirect_to :action => 'edit'
  end
  
  def deposit
    @deposit = params[:deposit][0].to_i
    if TxWrapper.take(@pc, :gold, @deposit)
      flash[:notice] = 'Amount to withdrawl cannot exceed the gold in the coffers.'
    else
      TxWrapper.give(session[:kingdom], :gold, @deposit)
      flash[:notice] = 'Withdrawl successful.'
    end
    redirect_to :action => 'edit'
  end
  
  def adjust_tax
    if params[:taxes][0].to_f < 0 || params[:taxes][0].to_f > 100
      flash[:notice] = 'Tax rate must be between 0% and 100%'
    else
      session[:kingdom].tax_rate = params[:taxes][0].to_f
      session[:kingdom].save!
      flash[:notice] = 'Tax rate updated.'
    end
    redirect_to :action => 'edit'
  end
end
