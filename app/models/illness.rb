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
				if who.class == PlayerCharacter || who.class == Npc #only Npc and Pc have this attr
					who.health.update_attributes( {'wellness', SpecialCode.get_code('wellness','diseased')} ) 
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
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page, oid = nil)
		if oid.nil?
			paginate(:page => page,
							 :joins => 'INNER JOIN diseases on disease_id = diseases.id' , :order => 'name' )
		else
			paginate(:page => page,
						 :joins => 'INNER JOIN diseases on disease_id = diseases.id',
				 :conditions => ['owner_id = ?', oid], :order => 'name' )
	end
	end
end