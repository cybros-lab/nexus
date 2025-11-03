class CreateIndexedFiles < ActiveRecord::Migration[8.2]
  def change
    create_table :indexed_files do |t|
      t.string :key, null: false, comment: "quick identifier, calculated by `storage_path`"

      t.string :storage_path, null: false, comment: "original storage path (relative to the root)"
      t.string :file_name, null: false, comment: "original filename"
      t.timestamp :modified_at, null: false, comment: "original file's `mtime` attribute"

      t.string :content_type, null: false, comment: "Detected MIME type"
      t.bigint :byte_size, null: false
      t.string :checksum, null: false

      t.timestamps

      t.index :key
      t.index %i[storage_path file_name], unique: true
    end
  end
end
