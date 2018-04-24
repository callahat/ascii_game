require 'test_helper'

class Management::QuestReqsControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @quest = quests(:quest_one)
    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
  end

  test "can't use a quest that is active" do
    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'active')
    get :type, quest_id: @quest
    assert_redirected_to management_quest_path(@quest)
    assert_match /cannot be edited; it is already being used\./, flash[:notice]
  end

  test "type" do
    get :type, quest_id: @quest
    assert_response :success
    assert_not_nil assigns(:reqs)
  end

  test "should get new" do
    SpecialCode.get_codes_and_text('quest_req_type').each do |type, _number|
      get :new, quest_id: @quest, type: type
      assert_response :success
      assert_not_nil assigns(:quest_req)
    end
  end

  test "should create quest_req" do
    assert_no_difference 'QuestReq.count' do
      post :create, quest_id: @quest, type: 'creature_kill', quest_req: {quantity: 0, detail: Creature.first.id}
      assert_equal "Requirement failed to save.", flash[:notice]
    end

    [ ["creature_kill", {quantity: 1, detail: Creature.first.id}],
      ["explore", {detail: events(:quest_event_one).id} ],
      ["item", {quantity: 1, detail: items(:cool_item).id}],
      ["kill_any_npc", {quantity: 1, detail: "#{SpecialCode.get_code('npc_division','peasant')}:#{Kingdom.first.id}"}],
      ["kill_pc", {detail: PlayerCharacter.first.id}],
      ["kill_specific_npc", {detail: Npc.first.id}]].each do |type, params|

      assert_difference('QuestReq.count') do
        post :create, quest_id: @quest, type: type,
             quest_req: params
      end
      assert_redirected_to management_quest_path(@quest)
    end
  end

  test "should get edit" do
    SpecialCode.get_codes_and_text('quest_req_type').each do |type, _number|
      get :edit, quest_id: @quest, id: @quest.creature_kills.first
      assert_response :success
      assert_not_nil assigns(:quest_req)
    end
  end

  test "should update quest_req" do
    patch :update, quest_id: @quest, id: @quest.creature_kills.first, quest_req: {quantity: 0, detail: Creature.first.id}
    assert_equal 'Requirement failed to update.', flash[:notice]

    [ ["creature_kills", {quantity: 1, detail: Creature.last.id}],
      ["explores", {detail: events(:quest_event_two).id} ],
      ["items", {quantity: 1, detail: items(:item_99).id}],
      ["kill_n_npcs", {quantity: 1, detail: "#{SpecialCode.get_code('npc_division','guard')}:#{Kingdom.first.id}"}],
      ["kill_pcs", {detail: PlayerCharacter.last.id}],
      ["kill_s_npcs", {detail: Npc.last.id}]].each do |type, params|

      patch :update, quest_id: @quest, id: @quest.send(type).first,
           quest_req: params
      assert_redirected_to management_quest_path(@quest)
    end
  end

  test "should destroy management_quest_req" do
    @quest.reqs.each do |req|
      assert_difference('QuestReq.count', -1) do
        delete :destroy, quest_id: @quest, id: req
      end

      assert_redirected_to management_quest_path(@quest)
    end
  end
end
