#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::TeamsHelper
  def number_of_groups
    @team.groups_count
  end

  def number_of_accounts
    @team.accounts_count
  end

end
