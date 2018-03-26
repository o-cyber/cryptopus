class AddCounterCaches < ActiveRecord::Migration[5.1]
  def up
    add_column :teams, :groups_count, :integer
    add_column :teams, :accounts_count, :integer

    Team.find_each do |team|
      team.update_column('groups_count', team.groups.count)
      
      accounts = 0
      team.groups.each do |group|
        accounts += group.accounts.count
      end
      team.update_column('accounts_count', accounts)
    end
  end

  def down
    remove_column :teams, :groups_count
    remove_column :teams, :accounts_count
  end
end
