module IntegrationTest
  module AccountTeamSetupHelper
    def create_team_group_account(username, user_password = 'password', noroot = false, private = false)
      login_as(username.to_s, user_password)

      #New Team
      post teams_path, team: {name: 'Web', description: 'team_description', private: private, noroot: noroot}

      #New Group
      team = Team.find_by_name('Web')
      post team_groups_path(team_id: team.id), group: {name: 'Default', description: 'group_description'}

      #New Account
      group = team.groups.find_by_name('Default')
      account_path = team_group_accounts_path(team_id: team.id, group_id: group.id)
      post account_path, account: {accountname: 'puzzle', description: 'account_description', username: 'account_username', password: 'account_password'}

      logout
      group.accounts.find_by_accountname('puzzle')
    end

    def create_team_group_account_noroot(username, user_password = 'password')
      create_team_group_account(username, user_password, true)
    end

    def create_team_group_account_private(username, user_password = 'password')
      create_team_group_account(username, user_password, false, true)
    end

    def create_team_group_account_private_noroot(username, user_password = 'password')
      create_team_group_account(username, user_password, true, true)
    end

    def create_team(user, teamname, private_team, noroot_team)
      team = Team.create(name: teamname, description: 'team_description', private: private_team, noroot: noroot_team)
      team_password = cipher.random_key()
      crypted_team_password = CryptUtils.encrypt_blob user.public_key, team_password
      Teammember.attr_accessible :team_id, :password
      Teammember.create(team_id: team.id, password: crypted_team_password )
    end

    def create_group(team, groupname)
      Group.create(team_id: team.id, name: groupname, description: 'group_description')
    end

    def create_account(group, groupname, accountname)
      Account.create(group_id: group.id,accountname: accountname, description: 'account_description', username: 'account_username', password: 'account_password')
    end
  end
end