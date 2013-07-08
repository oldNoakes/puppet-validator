require 'puppet-lint'
require 'common/verifyer'

module Validator
  class Lint
    include Verifyer
    require 'monkey/lint'

    def initialize location
      @location = location || "."
      @type = :lint
    end

    def execute manifest
      PuppetLint.configuration.send('disable_double_quoted_strings')
      linter = PuppetLint.new
      linter.file = manifest
      results = Hash.new { |result,kind| result[kind] = [] }
      linter.run.each do |issue|
        results[issue[:kind]] << "#{issue[:check].upcase}: #{issue[:message]} at line:#{issue[:linenumber]}"
      end
      results
    end
  end
end
