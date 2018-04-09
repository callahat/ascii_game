class KingdomNotice < ActiveRecord::Base
  belongs_to :kingdom

  validates_presence_of :text,:shown_to

  #attr_accessible :text, :shown_to, :signed, :kingdom_id

  default_scope { order("created_at DESC") }

  def self.create_storm_gate_notice(name, kid)
    #create kingdom notice of a player storming the gate
    create(  :kingdom_id => kid,
            :shown_to => SpecialCode.get_code('shown_to','king'),
            :text => name + " stormed the gates and gained entry to the kingdom.",
            :signed => "Captain of the Guard")
  end

  def self.create_coup_notice(name, kid)
    create(  :kingdom_id => kid,
            :shown_to => SpecialCode.get_code('shown_to','everyone'),
            :text => "The former king has been violently overthrown by " + name + " who has assumed the crown",
            :signed => "Minister of the Interior")
  end

  def self.create_notice(text, kid, signor="Minister of the Interior")
    create(  :kingdom_id => kid,
            :shown_to => SpecialCode.get_code('shown_to','everyone'),
            :text => text,
            :signed => signor)
  end

  #Pagination related stuff
  def self.per_page
    20
  end

  def self.get_page(page, pc = nil, k = nil)
    conds = []
    if k.nil?
    elsif pc.nil? || pc.id == k.player_character_id
      conds = ['kingdom_id = ?', k.id]
    elsif pc.kingdom_id == pc.in_kingdom
      conds = ['kingdom_id = ? AND (shown_to = ? OR shown_to = ?)',
                k.id,
                SpecialCode.get_code('shown_to','everyone'),
                SpecialCode.get_code('shown_to','allies')]
    else
      conds = ['kingdom_id = ? AND shown_to = ?',
                k.id,
                SpecialCode.get_code('shown_to','everyone')]
    end
    where(conds) \
      .paginate(:per_page => 20, :page => page)
  end
end
