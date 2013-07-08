require 'validator/librarian'

module Validator
  class TestLibrarian < Validator::Librarian
    def initialize(location = ".", clean = true)
      @location = Locater.find_test_librarian(location)
      @clean = clean
    end
  end
end
