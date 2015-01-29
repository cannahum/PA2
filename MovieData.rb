require './MovieTest.rb'

class MovieData

    attr_reader :test_results
    
    def initialize(*args)
        if args.length == 1
            initialize_one(args[0])
        else
            initialize_two(args[0], args[1])
        end
    end
 
    def initialize_one(folder_name)

        training_data = Array.new
        file_path = File.join(folder_name, "u.data")
        my_file = open(file_path, 'r')
        my_file.each do |record|
            each_line = record.split(' ')
            training_data.push(each_line)
        end
        create_my_tables(training_data) 
    end

    
    def initialize_two(folder_name, file_name)

        training_data = Array.new
        file_path = File.join(folder_name, file_name)
        my_file = open(file_path, 'r')
        my_file.each do |record|
            each_line = record.split(' ')
            training_data.push(each_line)
        end
        create_my_tables(training_data)
    end


    def create_my_tables(training_data)
        # this creates the most essential tables needed for my algorithm
        # each of these structures is an hash of arrays
        # @user_ratings is a hash of users vs. an array of ratings.
        # @movies is a hash of movies vs. an array of ratings.

        @user_ratings = Hash.new
        @movies = Hash.new
        @similarity_matrix = Hash.new
        @test_results = Array.new

        user_arrays = 0
        movie_arrays = 0
        training_data.each do |entry|
            if @user_ratings[entry[0].to_i] == nil
                @user_ratings[entry[0].to_i] = Array.new
            end
            if @movies[entry[1].to_i] == nil
                @movies[entry[1].to_i] = Array.new
            end
            @user_ratings[entry[0].to_i][entry[1].to_i] = entry[2].to_i
            @movies[entry[1].to_i][entry[0].to_i] = entry[2].to_i
        end 
    end
    
    
    def rating(user, movie)
        # returns the rating that user has given for a particular movie
        rating = @user_ratings[user][movie]
        if rating == nil
            return 0
        else
            return rating
        end
    end


    def predict(user, movie)
        # this is interesting. It takes all the people who have seen the movie
        # then creates a similarity array for each viewer. Then it normalizes
        # each similarity so that if one were to add up each similarity it would
        # equal 100%. Then it takes a weighted average of ratings:
        # SUMMATION:(rating * normalized similarity)

        if @user_ratings[user][movie] != nil
            puts "User #{user} has already seen this movie."
            return rating(user, movie)
        end
        
        viewers = viewers(movie)
        similarity_against_viewers = []
        total_similarity = 0.0
        base = 0.0
        viewers.each do |viewer|
            if @similarity_matrix[user] == nil
                @similarity_matrix[user] = Array.new
            end
            if @similarity_matrix[viewer] == nil
                @similarity_matrix[viewer] = Array.new
            end

            if @similarity_matrix[user][viewer] == nil
                similarity = similarity(user, viewer)
                @similarity_matrix[user][viewer] = similarity
                @similarity_matrix[viewer][user] = similarity
            else
                similarity = @similarity_matrix[user][viewer]
            end
            total_similarity += similarity * rating(viewer, movie)
            base += similarity
        end
        
        if base == 0
            return 0
        else
            return total_similarity / base
        end
    end
    

    def movies(user)
        # returns an array of all the movies a particular user has reviewed.
        movies = []
        @user_ratings[user].each_with_index do |rating, index|
            if rating != nil
                movies.push(index)
            end
        end

        return movies
    end


    def viewers(movie)
        # returns an array of viewers who has seen a movie that's passed in as an argument
        users = []

        if @movies[movie] == nil
            return []
        else
            @movies[movie].each_with_index do |rating, index|
                if rating != nil
                    users.push(index)
                end
            end
        end
        return users
    end


    def similarity(user1, user2)
        # returns the similarity between two users. It looks at the common movies
        # the two users have seen and takes a Eucledian distance with respect to
        # each rating. Then it divides it to maximum possible distance to get % value.
        distance = 0.0
        count = 0
        @user_ratings[user1].each_with_index do |rating, index|
            if rating != nil && @user_ratings[user2][index] != nil
                distance += (@user_ratings[user2][index] - rating) ** 2
                count += 1 
            end
        end
        max_distance = (4 ** 2) * count
        similarity = 1 - (distance / max_distance)

        if count == 0
            return 0
        else
            return similarity
        end
    end


    def run_test(k)
        file_name = "u1.test"
        test = MovieTest.new(file_name)

        test.test_subjects[0...k].each do |line|
           prediction = predict(line[0].to_i, line[1].to_i)
           array = [line[0].to_i, line[1].to_i, prediction, line[2].to_i]
           @test_results.push(array)
        end

        test.to_a(@test_results)
        mean = test.mean(@test_results)
        puts "Mean of Error: #{mean}"
        puts "Standard Deviation of Error: #{test.stddev(@test_results, mean)}"
        puts "RMS of Error: #{test.rms(@test_results, mean)}"
    end
end
