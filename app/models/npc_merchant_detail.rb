class NpcMerchantDetail < ActiveRecord::Base
  belongs_to :npc_merchant, foreign_key: 'npc_id'

  attr_accessible :healing_sales,:blacksmith_sales,:trainer_sales,:consignor,:race_body_type

  def healer_skills
    HealerSkill.where(['min_sales <= ?', healing_sales]).order("min_sales DESC")
  end
  
  def max_skill_taught
    sk = TrainerSkill.order("min_sales DESC").find_by(['min_sales < ?', trainer_sales])
    sk ? sk.max_skill_taught : 0
  end
end
