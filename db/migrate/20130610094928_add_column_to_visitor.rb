class AddColumnToVisitor < ActiveRecord::Migration
  def change
  	add_column :visitors, :lhs_code, :string
  end
end
