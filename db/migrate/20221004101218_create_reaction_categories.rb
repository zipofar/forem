class CreateReactionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :reaction_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false
      t.string :icon, null: false
      t.float :score, default: 1.0
      t.boolean :editable, default: true
      t.boolean :privileged, default: false
      t.boolean :published, default: false

      t.timestamps
    end

    add_index(:reaction_categories, :slug, unique: true)
  end
end
