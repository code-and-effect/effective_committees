class CreateEffectiveCommittees < ActiveRecord::Migration[6.0]
  def change
    # Committees
    create_table :committees do |t|
      t.string :title
      t.string :slug

      t.integer :committee_members_count, default: 0
      t.integer :committee_folders_count, default: 0
      t.integer :committee_files_count, default: 0

      t.boolean :display_on_index, default: true
      t.boolean :display_on_dashboard, default: true

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
      t.string :category

      t.date :start_on
      t.date :end_on

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :committee_members, [:committee_id]
    add_index :committee_members, [:user_id, :user_type]
    add_index :committee_members, :user_id, if_not_exists: true
    add_index :committee_members, :committee_id, if_not_exists: true

    create_table :committee_folders do |t|
      t.integer :committee_id
      t.string :committee_type

      t.string :committee_folder_id

      t.string :title
      t.string :slug

      t.integer :position
      t.integer :committee_files_count, default: 0

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :committee_folders, [:committee_id, :committee_type]
    add_index :committee_folders, [:position]
    add_index :committee_folders, :committee_id, if_not_exists: true

    create_table :committee_files do |t|
      t.integer :committee_id
      t.string :committee_type

      t.integer :committee_folder_id

      t.integer :file_id
      t.datetime :file_created_at

      t.string :title
      t.text :notes

      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :committee_files, :committee_id, if_not_exists: true
    add_index :committee_files, :title, if_not_exists: true
  end
end
