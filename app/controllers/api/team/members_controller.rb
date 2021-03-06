# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::MembersController < ApiController

  # GET /api/teams/:team_id
  def index
    authorize team, :list_members?
    members = team.teammembers.list
    render_json members
  end

  # GET /api/teams/:team_id/members/candidates
  def candidates
    authorize team, :team_member?
    candidates = team.member_candidates
    render_json candidates
  end

  # POST /api/teams/:team_id/members
  def create
    authorize team, :add_member?
    new_member = User.find(params[:user_id])

    decrypted_team_password = team.decrypt_team_password(current_user, session[:private_key])

    team.add_user(new_member, decrypted_team_password)

    add_info(t('flashes.api.members.added', username: new_member.username))
    render_json ''
  end

  # DELETE /api/teams/:team_id/members/:id
  def destroy
    authorize team, :remove_member?
    teammember.destroy!

    username = User.find(params[:id]).username
    add_info(t('flashes.api.members.removed', username: username))
    render_json ''
  end

  private

  def teammember
    @teammember ||= team.teammembers.find_by(user_id: params[:id])
  end
end
