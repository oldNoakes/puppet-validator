require 'common/locater'

module Validator
  class Librarian
    def initialize(location = ".", clean = false)
      @location = Locater.find_librarian(location)
      @clean = clean
    end

    def run
      return unless @location
      verify_puppet_librarian
      install_puppet_librarian
    end

    def install_puppet_librarian
      command = "librarian-puppet install"
      command << " --clean" if @clean
      Dir.chdir(Locater.find_librarian(@location)) {
        raise "Puppet Librarian failed to run" unless run_command command
      }
    end

    def verify_puppet_librarian
      raise "Please install librarian-puppet gem" unless run_command("/usr/bin/which librarian-puppet")
    end

    def run_command(command, fail_on_error = true)
      puts "running command: #{command}"
      puts %x[#{command}]
      $?.success?
    end
  end
end
