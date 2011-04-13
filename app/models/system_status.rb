class SystemStatus < ActiveRecord::Base
  def self.status(sys)
    find(sys).status
  end

  def self.stop(sys)
    s = find(sys)
    s.status = 0
    s.save
  end

  def self.start(sys)
    s = find(sys)
    s.status = 1
    s.save
  end
end
