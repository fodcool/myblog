class AddColumnPageViewCountToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :page_view_count, :integer, default: 10
  end
end
