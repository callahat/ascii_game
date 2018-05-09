class NpcGuard < Npc
  def self.generate(kingdom_id)
    @kingdom_name = Kingdom.find(kingdom_id).name
    @image = Image.find_by(name: @kingdom_name + " Guard Image", kingdom_id: kingdom_id)

    @new_stock_guard = self.create(
        :name => ("Guard " + Name.gen_name)[0...32],
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
    @image = Image.new(
        image_text: DEFUALT_NPC_IMAGE,
        public: false,
        image_type: SpecialCode.get_code('image_type','kingdom'),
        player_id: -1
    )

    @image.kingdom_id = kingdom_id
    @image.name = @kingdom_name + " Guard Image"
    @image.save!
  end

  protected
  DEFUALT_NPC_IMAGE = <<-ASCII

            /\'\
      _|_ <_XX  }
     /   \  ||./
    / === \ ||
  ------""_ ||
  |    |' _@d3
  |    | :; ||
  \    /':; ||
   \__/'''  ||
    [M] [[> \/
  ASCII
end
