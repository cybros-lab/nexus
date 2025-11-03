class IndexedFile < ApplicationRecord
  validates :storage_path,
            presence: true

  validates :file_name,
            presence: true,
            uniqueness: { scope: :storage_path }

  validates :key, :modified_at, :content_type, :byte_size, :checksum,
            presence: true

  def absolute_full_path
    Utils::FileSystem.root_path.join(storage_path).join(file_name).to_path
  end

  def relative_full_path
    Pathname.new(storage_path).join(file_name).to_path
  end
end
