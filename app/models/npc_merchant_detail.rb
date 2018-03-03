class NpcMerchantDetail < ActiveRecord::Base
  belongs_to :npc_merchant, foreign_key: 'npc_id'
  
  def healer_skills
    HealerSkill.find(:all, :conditions => ['min_sales <= ?', healing_sales], :order => '"min_sales DESC"')
  end
  
  def max_skill_taught
    ((sk = TrainerSkill.find(:first, :conditions => ['min_sales < ?', trainer_sales], :order => '"min_sales DESC"')) ?
      sk.max_skill_taught : 0 )
  end
end
