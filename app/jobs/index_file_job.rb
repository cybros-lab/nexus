class IndexFileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    unless File.exist?(file_path)
      return
    end


    record = IndexedFile.find_or_initialize_by(
      key: Utils::FileSystem.path_checksum(file_path),
      storage_path: Utils::FileSystem.relative_path(file_path).dirname.to_path,
    )

    record.file_name = Utils::FileSystem.file_name(file_path)
    record.modified_at = File.mtime(file_path)
    record.content_type = Utils::FileSystem.mime_type(file_path)
    record.byte_size = File.size(file_path)
    record.checksum = Utils::FileSystem.file_checksum(file_path)

    record.save!
  end
end
