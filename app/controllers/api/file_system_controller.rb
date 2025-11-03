class Api::FileSystemController < Api::ApplicationController
  def index
    requested_path = params[:requested_path].to_s
    if requested_path.include?("./")
      render status: :bad_request,
             json: {
               error: {
                 code: "BAD_REQUESTED_PATH",
               },
             }
      return
    end

    current_path = Utils::FileSystem.root_path.join(requested_path)
    unless File.exist?(current_path)
      render status: :not_found,
             json: {
               error: {
                 code: "NOT_FOUND",
               },
             }
      return
    end

    relative_path = Utils::FileSystem.relative_path(current_path)
    if File.directory?(current_path)
      files = Dir.glob("#{current_path}/*")
      unless Utils::Cli.true? params[:all]
        files.select! { Utils::FileSystem.allow?(it) }
      end

      indexed_files = IndexedFile.where(storage_path: relative_path.to_path).to_a

      render json: {
        directory: {
          full_path: relative_path.to_path,
          entries: files.map do |path|
            indexed_file = indexed_files.find { it.file_name == File.basename(path) }

            {
              file_name: indexed_file&.file_name || Utils::FileSystem.file_name(path),
              type: File.directory?(path) ? "directory" : "file",
              indexed: indexed_file.present?,
              metadata: indexed_file.blank? ? nil : {
                key: indexed_file.key,
                checksum: indexed_file.checksum,
                byte_size: indexed_file.byte_size,
                content_type: indexed_file.content_type,
              },
            }
          end,
        },
      }
    else
      indexed_file = IndexedFile.find_by(storage_path: relative_path.dirname.to_path, file_name: relative_path.basename.to_s)
      render json: {
        full_path: indexed_file&.relative_full_path || Utils::FileSystem.relative_path(current_path).to_path,
        filename: indexed_file&.file_name || Utils::FileSystem.file_name(relative_path),
        type: "file",
        indexed: indexed_file.present?,
        metadata: indexed_file.blank? ? nil : {
          key: indexed_file.key,
          checksum: indexed_file.checksum,
          byte_size: indexed_file.byte_size,
          content_type: indexed_file.content_type,
        },
      }
    end
  end
end
