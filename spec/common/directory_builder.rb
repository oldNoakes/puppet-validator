require 'fileutils'
module DirectoryBuilder
  def build_directory_structure *dirs
    dirs.each do |dir|
      location = File.join(@root_dir, dir)
      FileUtils.mkdir_p(location)
    end
  end

  def add_files directory, *files
    files.each do |file|
      location = File.join(@root_dir, directory, file)
      FileUtils.touch(location)
    end
  end
end
