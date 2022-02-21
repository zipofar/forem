class CreateFeedSourceUrlIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :articles, :feed_source_url, algorithm: :concurrently
  end

  def down
    remove_index :articles, column: :feed_source_url, algorithm: :concurrently
  end
end
