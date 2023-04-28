require 'date'

class PhotoRenamer

  # Renames a list of photos given as an input string.
  #
  # @param input_string [String] The input string containing photo information.
  # @return [String] The renamed photos as a string.
  def photo_renamer(input_string)
    parsed_photos = parse_photos_from_string(input_string)
    grouped_cities = group_photos_by_city(parsed_photos)
    sorted_photos = sort_photos_by_city_and_time(grouped_cities)
    rename_photos(sorted_photos)
  end

  # Parses a list of photos from an input string.
  #
  # @param input_string [String] The input string containing photo information.
  # @return [Array<Hash>] An array of photo hashes with parsed information.
  def parse_photos_from_string(input_string)
    lines = input_string.split("\n")
    validate_input(lines)
    photos = []

    lines.each_with_index do |line, index|
      name, extension, city, date_time = line.match(/(.+)\.(.+),\s+(.+),\s+(.+)/).captures
      photos << {
        index: index,
        name: name,
        extension: extension,
        city: city,
        date_time: DateTime.strptime(date_time, '%Y-%m-%d %H:%M:%S'),
      }
    end

    photos
  end

  # Groups parsed photos by city.
  #
  # @param parsed_photos [Array<Hash>] An array of photo hashes with parsed information.
  # @return [Hash] A hash containing city names as keys and arrays of photos as values.
  def group_photos_by_city(parsed_photos)
    grouped_cities = {}

    parsed_photos.each do |photo|
      grouped_cities[photo[:city]] ||= []
      grouped_cities[photo[:city]] << photo
    end

    grouped_cities
  end

  # Sorts photos by city and time.
  #
  # @param grouped_cities [Hash] A hash containing city names as keys and arrays of photos as values.
  # @return [Hash] A hash containing sorted photos by city and time.
  def sort_photos_by_city_and_time(grouped_cities)
    grouped_cities.map do |city, photos|
      [city, photos.sort_by { |photo| photo[:date_time] }]
    end.to_h
  end

  # Renames photos according to the new naming convention.
  #
  # @param photos [Hash] A hash containing sorted photos by city and time.
  # @return [String] The renamed photos as a string.
  def rename_photos(sorted_photos)
    renamed_photos = []

    sorted_photos.each do |city_name, city_photos|
      max_digits = city_photos.size.to_s.length

      city_photos.each_with_index do |photo, index|
        new_name = "#{photo[:city]}#{(index + 1).to_s.rjust(max_digits, '0')}.#{photo[:extension]}"
        renamed_photos[photo[:index]] = new_name
      end
    end

    renamed_photos.join("\n")
  end

  private
  
  # Validates the input string according to the specified rules.
  #
  # @param lines [Array<String>] An array of lines from the input string.
  # @raise [ArgumentError] Raises an ArgumentError if any validation fails.
  def validate_input(lines)
    lines.each do |line|
      old_name, city, timestamp = line.split(', ')
      name, extension = old_name.split('.')
      
      raise ArgumentError, 'Invalid number of photos' if lines.size < 1 || lines.size > 100
      raise ArgumentError, 'Invalid year' if timestamp[0..3].to_i < 2000 || timestamp[0..3].to_i > 2020
      raise ArgumentError, 'Invalid photo or city name' if name.size < 1 || name.size > 20 || city.size < 1 || city.size > 20
      raise ArgumentError, 'Invalid city name format' unless city[0] == city[0].upcase && city[1..-1] == city[1..-1].downcase
      raise ArgumentError, 'Invalid extension' unless %w[jpg png jpeg].include?(extension)
    end
  end

end
