namespace :test do
  desc "Loops over all sorts of weight configurations and dumps results"
  task weighting_rounds: :environment do
    results = []

    CHOICES = [1, 3, 5]
    num_weights = Suggestion::WEIGHTS.size

    @results = CHOICES.inject([]) { |res, num| res << Array.new(num_weights, num) }
      .flatten
      .permutation(num_weights)
      .to_a
      .uniq
      .inject([]) do |results, combination|

      weights = combination.each_with_index.inject({}) do |res, (weight, index)|
        res[Suggestion::WEIGHTS.keys[index]] = weight ; res
      end

      result = `WEIGHTS='#{weights.to_yaml}' rspec`

      success = 100 - result[/\d+ failures/].to_i
      finals  = result[/Final Results: (.+)/]
                    .gsub('Final Results: ', '')
                    .split('-')
                    .map(&:to_i)

      spread = finals.max - finals.min
      `echo "#{success}% - #{spread}: #{weights}" >> ./results.txt`

      results << {spread: spread, result: success, weights: weights}
    end

    File.open('./sorted_results.txt', 'wb') do |f|
      @results.sort { |b, c| [b[:spread], b[:result]] <=> [c[:spread], c[:result]] }.each do |result|
        f.write "#{result[:result]}% - #{result[:spread]}: #{result[:weights]}\n"
      end
    end
  end
end
