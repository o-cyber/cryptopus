# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Team < ActiveRecord::Base
  has_many :groups, -> {order :name}, :dependent => :destroy
  has_many :teammembers, :dependent => :delete_all

  def teammember_candidates
    excluded_user_ids = User.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
                          where('users.uid = 0 OR users.admin = ? OR teammembers.team_id = ?', true, id).
                          distinct.
                          pluck(:id)
    User.where('id NOT IN(?)', excluded_user_ids)
  end

  def last_teammember?
    teammembers.count == 1
  end
end
