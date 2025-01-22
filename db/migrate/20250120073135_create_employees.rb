class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :employee_id
      t.string :name
      t.string :phone
      t.datetime :registered_at

      t.timestamps
    end
  end
end
