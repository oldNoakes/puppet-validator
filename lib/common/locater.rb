module Locater
  def self.find_modules(project_root)
    modules = Dir["#{project_root}/**/"].select { |directory| directory.end_with?("modules/") }
    raise "No valid modules found" if modules.empty?
    #Strip trailing slash!
    modules.map { |module_dir| File.expand_path(module_dir).chomp("/") }
  end

  def self.find_site_manifest(project_root)
    default_location = File.expand_path(File.join(project_root, "manifests"))
    raise "No valid site.pp file found" unless File.exists?(File.join(default_location, "site.pp"))
    default_location
  end

  def self.find_test_manifests(module_root)
    default_location = File.expand_path(File.join(module_root, "tests"))
    tests = Dir.glob("#{default_location}/*.pp")
    raise "No valid test files found" if tests.empty?
    tests
  end

  def self.find_test_librarian(module_root)
    default_location = File.expand_path(File.join(module_root, "tests", "dependencies", "Puppetfile"))
    File.exists?(default_location) ? File.dirname(default_location) : nil
  end

  def self.find_librarian(project_root)
    default_location = File.expand_path(File.join(project_root, "dist", "Puppetfile"))
    location = File.exists?(default_location) ? default_location : search_for_puppetfile(project_root)
    location ? File.dirname(location) : nil
  end

  def self.search_for_puppetfile(project_root)
    Dir.glob("#{File.expand_path(project_root)}/**/Puppetfile").first
  end

  def self.find_all_manifests(project_root)
    Dir.glob("#{File.expand_path(project_root)}/**/*.pp")
  end
end
