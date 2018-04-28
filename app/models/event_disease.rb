class EventDisease < Event
  belongs_to :disease, :foreign_key => 'thing_id'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Disease'

  validates_presence_of :thing_id
  
  def price
    flex ? Disease.abs_cost(disease) : 0
  end
  
  def make_happen(who)
    if self.flex
      if Illness.cure(who, self.disease)
        @message = 'Your case of ' + disease.name + ' has cleared up!'
      else
        #no point in going on, player already healthy, nothing happens.
        @message = '...Nothing interesting happened.'
      end
    elsif Illness.infect(who, self.disease)
      @message = 'You don\'t feel so good...'
    else
      #don't infect someone with the same organism more than once
      @message = 'This place feels unhealthy'
    end
    
    return nil, EVENT_COMPLETED, @message
  end
  
  def as_option_text(pc=nil)
    if flex
      @link_text = "Cure " + disease.name
    else
      @link_text = "Get infected with " + disease.name
    end
  end
end
