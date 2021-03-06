# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::MembersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  test 'returns team member candidates for new team' do
    login_as(:admin)
    team = Team.create(users(:admin), {name: 'foo'})

    get :candidates, params: { team_id: team }, xhr: true

    candidates = JSON.parse(response.body)['data']['user/humen']

    assert_equal 3, candidates.size
    assert candidates.any? {|c| c['label'] == 'Alice test' }, 'Alice should be candidate'
    assert candidates.any? {|c| c['label'] == 'Bob test' }, 'Bob should be candidate'
    assert candidates.any? {|c| c['label'] == 'Tux Miller' }, 'Configuration should be candidate'
  end

  test 'returns team members for given team' do
    login_as(:admin)

    team = teams(:team1)
    teammembers(:team1_bob).destroy!
    user = users(:alice)

    api_user = user.api_users.create!
    alices_private_key = user.decrypt_private_key('password')
    plaintext_team_password = team.decrypt_team_password(user, alices_private_key)

    team.add_user(api_user, plaintext_team_password)

    get :index, params: { team_id: team }, xhr: true

    members = JSON.parse(response.body)['data']['teammembers']

    assert_equal 3, members.size
    assert members.any? {|c| c['label'] == 'Alice test' }, 'Alice should be in team'
    assert members.any? {|c| c['label'] == 'Admin test' },  'Admin should be in team'
    assert members.none? {|c| c['label'] == api_user.label }, 'should not include any api users'
  end

  test 'creates new teammember for given team' do
    login_as(:admin)
    team = teams(:team1)
    user = Fabricate(:user)

    post :create, params: { team_id: team, user_id: user }, xhr: true

    assert team.teammember?(user), 'User should be added to team'
  end

  test 'does not remove admin from non private team' do
    login_as(:alice)

    assert_raise do
      delete :destroy, params: { team_id: teams(:team1), id: users(:admin) }, xhr: true
    end
  end

  test 'remove teammember from team' do
    login_as(:alice)
    assert_difference('Teammember.count', -1) do
      delete :destroy, params: { team_id: teams(:team1), id: user }, xhr: true
    end
  end
  
  test 'remove human user and his api users from team' do
    api_user = user.api_users.create
    bobs_private_key = user.decrypt_private_key('password')
    plaintext_team_password = teams(:team1).decrypt_team_password(user, bobs_private_key)

    teams(:team1).add_user(api_user, plaintext_team_password)

    login_as(:alice)
    assert_difference('Teammember.count', -2) do
      delete :destroy, params: { team_id: teams(:team1), id: user }, xhr: true
    end
    assert_equal false, teams(:team1).teammember?(user)
    assert_equal false, teams(:team1).teammember?(api_user)
  end
  
  context 'api user' do
    test 'add api user to team' do
      login_as(:bob)
      team = teams(:team1)
      api_user = user.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      assert team.teammember?(api_user), 'User should be added to team'
  end
  
    test 'remove api user from team' do
      login_as(:admin)
      team = teams(:team1)
      api_user = user.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      assert_difference('Teammember.count', -1) do
        delete :destroy, params: { team_id: teams(:team1), id: api_user }, xhr: true
      end
    end
  end

  private

  def user
    users(:bob)
  end
end
