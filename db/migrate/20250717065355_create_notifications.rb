class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :text
      t.string :target_ip
      t.string :status

      t.timestamps
    end
  end
end
