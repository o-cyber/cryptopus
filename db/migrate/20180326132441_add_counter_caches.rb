class AddCounterCaches < ActiveRecord::Migration[5.1]
  def up
    add_column :teams, :groups_count, :integer, default:0
    add_column :teams, :accounts_count, :integer, default:0
    
    Team.find_each { |team| Team.reset_counters(team.id, :groups, :accounts) }
  end

  def down
    remove_column :teams, :groups_count
    remove_column :teams, :accounts_count
  end
end
