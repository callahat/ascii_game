class ResizeFeatureImages < ActiveRecord::Migration
  def self.up
    Image.where(image_type: SpecialCode.get_code('image_type','kingdom'),
                image_type: SpecialCode.get_code('image_type','world')).each{|img|
      img.resize_image(10,15)
      img.save!
      print "Resizing " + img.name + "\n"
    }
  end

  def self.down
  end
end
