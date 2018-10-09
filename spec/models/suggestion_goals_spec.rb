require "rails_helper"
$results = Array.new(10, 0)

RSpec.describe Suggestion, :type => :model do
  context "using Database.xlsx" do
    weights = YAML.load(ENV['WEIGHTS']) rescue Suggestion::WEIGHTS

    RubyXL::Parser.parse(ENV['DB_LOCATION'])['Suggestions'][1..-1].each_with_index do |suggestion, index|
      business = Business.find_by_name(suggestion[0].value)
      next unless business

      suggestions = business.update_suggestions!(weights).limit(10).collect(&:name)
      goals = suggestion[1..-1].collect(&:value)

      context "Suggestions for #{business.name}" do
        10.times do |i|
          it "must contain #{goals[i]}" do
            assertion = suggestions.include?(goals[i])
            $results[index] += assertion ? 1 : 0
            puts "Final Results: #{$results.join('-')}" if [index, i].sum == 18
            assert assertion
          end
        end
      end
    end
  end
end
