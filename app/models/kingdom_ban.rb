class KingdomBan < ActiveRecord::Base
  belongs_to :kingdom
  belongs_to :player_character
  
  validates_presence_of :kingdom_id,:name
  
  class PlayerExistsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record[:player_character_id].nil?
        record.errors[:name] << "Character \"" + record[:name].to_s + "\" does not exist."
      end
    end
  end

  validates :player_character_id, :player_exists => true
  
  #Pagination related stuff
  def self.get_page(page, kid = nil)
    where(kid ? ['kingdom_id = ?', kid] : []) \
      .order('name') \
      .paginate(:per_page => 30, :page => page)
  end
end
