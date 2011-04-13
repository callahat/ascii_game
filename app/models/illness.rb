class Illness < ActiveRecord::Base
  self.inheritance_column = 'kind'
  belongs_to :disease
  
  def self.spread(host, target, trans_method)
    caught=0
    #spread disease to target
    @illnesses = host.illnesses.find(:all, :joins => "INNER JOIN diseases ON diseases.id = disease_id",
                                     :conditions => ['diseases.trans_method = ?', trans_method])
    for illness in @illnesses
      @disease = illness.disease
      caught +=1 if Illness.infect(target, @disease)
    end
    return caught > 0
  end
  
  def self.infect(who, disease)
    transaction do
    @tl = TableLock.find(:first, :conditions => {:name => who.illnesses.sti_name}, :lock => true)
    who.lock!
      @illness = who.illnesses.find(:first, :conditions => ['owner_id = ? and disease_id = ?', who.id, disease.id])
      @ret = false

      if @illness.nil? && disease.virility > rand(100) && rand(who[:con].to_i) < 500
        @ret = who.illnesses.create(:owner_id => who.id, :disease_id => disease.id)
        if who.class == PlayerCharacter || who.class.base_class == Npc #only Npc and Pc have this attr
          who.health.update_attribute(:wellness, SpecialCode.get_code('wellness','diseased') ) \
            if who.health.wellness != SpecialCode.get_code('wellness','dead')
          who.transaction do
            @stat = who.stat.lock!
            @stat.subtract_stats(disease.stat)
            @stat.save!
          end
        end
      end
      who.save!
      @tl.save!
    end
    return @ret
  end
  
  def self.cure(who, what)
    if (@illness = who.illnesses.find(:first, :conditions => ['disease_id = ?', what.id])) &&
        @illness.destroy
      if who.class == PlayerCharacter || who.class == Npc #only Npc and Pc have this attr
        who.health.update_attribute(:wellness, SpecialCode.get_code('wellness','alive') ) \
          if who.illnesses.size == 0 and who.health.wellness != SpecialCode.get_code('wellness','dead')
        who.transaction do
          who.stat.lock!
          who.stat.add_stats(what.stat)
          who.stat.save!
        end
      end
      return true
    else
      return false
    end
  end
  
  #Pagination related stuff
  def self.get_page(page, oid = nil)
    joins('INNER JOIN diseases on disease_id = diseases.id') \
      .where( oid ? ['owner_id = ?', oid] : [] ) \
      .order('name') \
      .paginate(:per_page => 20, :page => page)
  end
end
