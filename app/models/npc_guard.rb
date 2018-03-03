class NpcGuard < Npc
  def self.generate(kingdom_id)
    @kingdom_name = Kingdom.find(kingdom_id).name
    @image = Image.find_by(name: @kingdom_name + " Guard Image", kingdom_id: kingdom_id)

    @new_stock_guard = self.create(
        :name => "Guard " + Name.gen_name,
        :kingdom_id => kingdom_id,
        :gold => rand(50),
        :experience => 100,
        :is_hired => true,
        :image_id => @image.id
      )
    set_npc_stats(@new_stock_guard,60,10,10,10,10,10,10,10,30)
    return @new_stock_guard
  end

  def self.create_image(kingdom_id)
    @kingdom_name = Kingdom.find(kingdom_id).name
    @base_image = Image.find_by(name: "GUARD IMAGE", kingdom_id: -1, player_id: -1)
    @image = Image.deep_copy(@base_image)
    @image.kingdom_id = kingdom_id
    @image.name = @kingdom_name + " Guard Image"
    @image.save!
  end
end
