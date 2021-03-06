class CreateTimeOffPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :time_off_periods, id: :uuid do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.uuid :user_id, null: false
      t.uuid :organization_id, null: false
      t.integer :duration, null: false
      t.string :typology, null: false
      t.string :status, default: 'pending'
      t.string :notes
      t.timestamps
    end
  end
end
