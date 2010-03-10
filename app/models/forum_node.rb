class ForumNode < ActiveRecord::Base
	belongs_to :player
	belongs_to :forum_node

	has_many :childs, :foreign_key => 'forum_node_id', :class_name => 'ForumNode', :order => '"datetime DESC"'

	validates_uniqueness_of :name, :scope => [ :forum_node_id, :elders ]

	def last_posted_child
		if self.elders != 0
			print "Misuse of the last_posted_child function, object not a toplevel"
			return nil
		else
			#@last_thred = childs.find(:first, :conditions => ['forum_node_id = ?', self.id], :order => 'datetime')
			@last_thred = childs.find(:first)
			if @last_thred && @last_thred.childs.size > 0
				return @last_thred
			else
				return nil
			end
		end
	end

	def time_of_last_posted_child
		if (@thred = last_posted_child)
			return @thred.childs.first.datetime.strftime("%m-%d-%Y %I:%M.%S %p")
		else
			return nil
		end
	end

	def parent_forum_node(status) #is recursion even allowed? yes, at least it looks like it is.
		if self.elders == 0 
			return self[status]
		elsif self[status]
			return true
		else
			return self.forum_node.parent_forum_node(status)
		end
	end
	
	#Pagination related stuff
	def self.per_page
		15
	end
	
	def self.get_page(page, flags, bid = nil)
		if bid.nil?
			paginate(:page => page, :conditions => ['forum_node_id is NULL' + flags], :order => '"datetime DESC"' )
	else
		paginate(:page => page, :conditions => ['forum_node_id = ?' + flags, bid], :order => '"datetime DESC"' )
	end
	end
end
