class NpcMerchantDetail < ActiveRecord::Base
	belongs_to :npc_merchant
	
	def healer_skills
		HealerSkill.find(:all, :conditions => ['min_sales <= ?', healing_sales], :order => '"min_sales DESC"')
	end
end
