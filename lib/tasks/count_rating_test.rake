namespace :test do
  desc "Test Click Count Rating Algorithm"
  task check_count_rating: :environment do

    test_nums = [
      # [100, 10],
      [8, 8],
      [6, 7],
      [100, 5],
      [5, 20],
      [3, 60],
      [3, 10],
      [10, 3],
      [3, 3],
      # [2, 30],
      # [10, 2],
      # [20, 1],
      # [1, 1]
    ]

    def calculate_rating(pair)
      a = pair[0]
      b = pair[1]

      rating = 0
      # rating = (a + b) / (a * b).to_f # No, [3,3] is highest ranked
      # rating = (b) / (a + b).to_f * pair.min / 10 # No, no score above 0.4 rating
      rating = (a + b) / (pair.max * 2).to_f  * pair.min / 10 # Good rating dist (0.16 to 0.8)
      # rating = (a * b) / (pair.max ** 2).to_f  * pair.min / 10 # Ok, lower scores too low (0.02)
      # rating = ((a + b)/ 2) / (pair.max * 2 - pair.min).to_f  * pair.min / 10 #Ok, scores too low in general

      puts "Clicked_on: #{a}, clicked_by: #{b}, rating: #{rating.round(2)}"
    end

    test_nums.each do |pair|
      calculate_rating(pair)
    end
  end
end
