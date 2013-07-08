require 'erb'
require 'validator/erb_binder'

module Validator
  class StaticAnalysisReport
    OVERVIEW_TEMPLATE_FILE = File.expand_path("#{File.dirname(__FILE__)}/templates/puppet-static-analysis.erb")
    SPECIFIC_TEMPLATE_FILE = File.expand_path("#{File.dirname(__FILE__)}/templates/file-analysis.erb")

    def initialize report_root
      @report_root = report_root
    end

    def analyse results
      overview_results, sort_order = consolidate(results)
      overview_namespace = OpenStruct.new(:overview_results => overview_results, :order => sort_order)
      generate_html(OVERVIEW_TEMPLATE_FILE, overview_namespace, "puppet-static-analysis.html")
      results.each do |manifest, values|
        generate_html(SPECIFIC_TEMPLATE_FILE, OpenStruct.new(:specific_results => values, :name => manifest), manifest.gsub(File.extname(manifest), ".html"))
      end

      find_failures overview_results
    end

    def generate_html template, binding, report_name
      binder = ErbBinder.new(binding)
      overview_html = ERB.new(File.read(template), nil, '-').result(binder.get_binding)
      report_location = File.join(@report_root, report_name)
      FileUtils.mkdir_p File.dirname(report_location)
      File.open(File.expand_path(report_location), 'w') { |f| f.write(overview_html) }
    end

    def consolidate results
      consolidated_results = {}
      results.each do |key, result|
        consolidated_results[key] = {
          :href => File.join(".", key.gsub(File.extname(key), ".html")),
          :validate_errors => result[:validate][:error].count,
          :validate_warnings => result[:validate][:warning].count,
          :lint_errors => result[:lint][:error].count,
          :lint_warnings => result[:lint][:warning].count
        }
        consolidated_results[key][:score] = calculate_score consolidated_results[key]
        consolidated_results[key][:color] = get_color consolidated_results[key][:score]
      end
     return consolidated_results, sort_order(consolidated_results)
    end

    def sort_order results
      sorted_array = results.sort_by { |key, value| value[:score]}.reverse
      sorted_array.collect { |entry| entry[0] }
    end

    def calculate_score result
      result[:validate_errors] * 500 +
      result[:validate_warnings] * 5 +
      result[:lint_errors] * 5 +
      result[:lint_warnings] * 1
    end

    def get_color score
      return "FA0000" if score >= 500
      return "#{"%02X" % score}FA00" if score <= 250
      return "FA#{"%02X" % (500 - score)}00" if score < 500
    end

    def find_failures overview
      overview.select { |manifest, value| value[:score] >= 500 }
    end
  end
end
