class MovieTest

    attr_accessor :test_subjects
    
    def initialize(file_name)
        @test_subjects = []

        test_file = File.join("ml-100k", file_name)
        test_data = open(test_file, 'r')
        test_data.each do |record|
            each_line = record.split(' ')
            @test_subjects.push(each_line)
        end
    end


    def mean(test_results)
        count = 0
        summation = 0
        test_results.each do |list|
            count += 1
            summation += ((list[2] - list[3]) ** 2) ** 0.5
        end

        return summation / test_results.length
    end

    
    def stddev(test_results, mean)
        summation = 0
        test_results.each do |list|
            summation += ((list[2] - list[3]) ** 2 - mean ** 2) ** 2
        end

        return ((summation ** 0.5) / test_results.length) ** 0.5
    end


    def rms(test_results, mean)
         summation = 0
        test_results.each do |list|
            summation += (list[2] - list[3]) ** 2
        end

        return (summation / test_results.length) ** 0.5
    end


    def to_a(test_results)
        test_results.each do |list|
            puts "User: #{list[0]}, Movie: #{list[1]}, Prediction: #{list[2]}, Actual: #{list[3]}"
        end
    end
end           
