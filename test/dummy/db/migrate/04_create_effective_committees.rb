class CreateEffectiveCommittees < ActiveRecord::Migration[6.1]
  def change
    # Committees
    create_table :committees do |t|
      t.string :title
      t.string :slug
      t.integer :committee_members_count, default: 0

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :committees, :title
    add_index :committees, :slug

    # Representatives
    create_table :committee_members do |t|
      t.integer :committee_id
      t.string :committee_type

      t.integer :user_id
      t.string :user_type

      t.integer :roles_mask

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :committee_members, [:committee_id]
    add_index :committee_members, [:user_id, :user_type]

  end
end
