class CreateLhwDetails < ActiveRecord::Migration
  def change
    create_table :lhw_details do |t|
    	t.string :code
    	t.string :name
    	t.string :father_name
    	t.string :lhs_code
    	
      t.timestamps
    end
  end
end
