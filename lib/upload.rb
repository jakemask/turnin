##
# used for handling a file upload from a student
#
class Upload
  def initialize(ids, filetype, upload_dir)
    @folder = StudentID.to_group(ids).to_a.sort.join '_'
    @filename = @folder + Filetype::EXTENSION[filetype]
    @group_dir = File.join upload_dir, @folder

    loop do
      @timestamp = Time.now.to_i.to_s
      break unless Dir.exist? File.join(@group_dir, @timestamp)
    end
  end

  def copy(file)
    # determine file names
    out_dir = File.join @group_dir, @timestamp
    out_file = File.join out_dir, @filename

    # copy in the file
    FileUtils.mkdir_p out_dir
    FileUtils.cp file, out_file
  end

  def symlink
    # symlink 'latest' to point to the new submission
    latest = File.join @group_dir, 'latest'

    FileUtils.rm_f latest
    FileUtils.ln_sf @timestamp, latest
  end
end
