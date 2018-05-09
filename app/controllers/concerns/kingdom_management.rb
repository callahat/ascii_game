require 'active_support/concern'

# Found this trick from here: https://www.endpoint.com/blog/2016/02/22/devise-migration-legacy-rails-app
module KingdomManagement
  extend ActiveSupport::Concern

  included do
    before_filter :king_filter
    before_filter :setup_kingdom_vars, :except => ['choose_kingdom', 'select_kingdom']
    before_filter :setup_king_pc_vars, :except => ['choose_kingdom', 'select_kingdom']

    layout 'main'

    protected

    def setup_kingdom_vars
      redirect_to :action => 'choose_kingdom' unless @kingdom = session[:kingdom]
    end

  end
end
