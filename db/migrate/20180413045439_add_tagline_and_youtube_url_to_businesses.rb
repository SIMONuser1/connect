class AddTaglineAndYoutubeUrlToBusinesses < ActiveRecord::Migration[5.1]
  def change
    add_column :businesses, :tagline, :string
    add_column :businesses, :youtube_url, :string
  end
end
