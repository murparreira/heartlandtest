require_relative 'photo_renamer'
require 'rspec'

describe PhotoRenamer do
  let(:photo_renamer_instance) { PhotoRenamer.new }

  describe '#parse_photos_from_string' do
    it 'parses an input string into an array of photo data' do
      input_string = "photo.jpg, Krakow, 2013-09-05 14:08:15"
      expected_output = [
        {
          index: 0,
          name: "photo",
          extension: "jpg",
          city: "Krakow",
          date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
        },
      ]

      expect(photo_renamer_instance.parse_photos_from_string(input_string)).to eq(expected_output)
    end
  end

  describe '#validate_input' do
    it 'raises an error if the number of photos is out of range' do
      invalid_input = "photo.jpg, Krakow, 2013-09-05 14:08:15\n" * 101
      expect { photo_renamer_instance.photo_renamer(invalid_input) }.to raise_error(ArgumentError, 'Invalid number of photos')
    end

    it 'raises an error if the year is out of range' do
      invalid_input = "photo.jpg, Krakow, 1999-09-05 14:08:15"
      expect { photo_renamer_instance.photo_renamer(invalid_input) }.to raise_error(ArgumentError, 'Invalid year')
    end

    it 'raises an error if the photo or city name is invalid' do
      invalid_input = "photo.jpg, krakow, 2013-09-05 14:08:15"
      expect { photo_renamer_instance.photo_renamer(invalid_input) }.to raise_error(ArgumentError, 'Invalid city name format')

      invalid_input = "phototoolongabcdefghijklmnopqrst.jpg, Krakow, 2013-09-05 14:08:15"
      expect { photo_renamer_instance.photo_renamer(invalid_input) }.to raise_error(ArgumentError, 'Invalid photo or city name')
    end

    it 'raises an error if the extension is invalid' do
      invalid_input = "photo.bmp, Krakow, 2013-09-05 14:08:15"
      expect { photo_renamer_instance.photo_renamer(invalid_input) }.to raise_error(ArgumentError, 'Invalid extension')
    end
  end

  describe '#group_photos_by_city' do
    it 'groups parsed photos by city' do
      parsed_photos = [
        {
          index: 0,
          name: "photo",
          extension: "jpg",
          city: "Krakow",
          date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
        },
        {
          index: 1,
          name: "Mike",
          extension: "png",
          city: "London",
          date_time: DateTime.strptime('2015-06-20 15:13:22', '%Y-%m-%d %H:%M:%S'),
        },
        {
          index: 2,
          name: "myFriends",
          extension: "png",
          city: "Krakow",
          date_time: DateTime.strptime('2013-09-05 14:07:13', '%Y-%m-%d %H:%M:%S'),
        }
      ]

      expected_output = {
        "Krakow" => [
          {
            index: 0,
            name: "photo",
            extension: "jpg",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
          },
          {
            index: 2,
            name: "myFriends",
            extension: "png",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:07:13', '%Y-%m-%d %H:%M:%S'),
          },
        ],
        "London" => [
          {
            index: 1,
            name: "Mike",
            extension: "png",
            city: "London",
            date_time: DateTime.strptime('2015-06-20 15:13:22', '%Y-%m-%d %H:%M:%S'),
          },
        ],
      }

      expect(photo_renamer_instance.group_photos_by_city(parsed_photos)).to eq(expected_output)
    end
  end

  describe '#sort_photos_by_city_and_time' do
    it 'sorts photos in each city group by date and time' do
      grouped_cities = {
        "Krakow" => [
          {
            index: 0,
            name: "photo",
            extension: "jpg",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
          },
          {
            index: 1,
            name: "myFriends",
            extension: "png",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:07:13', '%Y-%m-%d %H:%M:%S'),
          },
        ],
      }

      expected_output = {
        "Krakow" => [
          {
            index: 1,
            name: "myFriends",
            extension: "png",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:07:13', '%Y-%m-%d %H:%M:%S'),
          },
          {
            index: 0,
            name: "photo",
            extension: "jpg",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
          },
        ],
      }

      expect(photo_renamer_instance.sort_photos_by_city_and_time(grouped_cities)).to eq(expected_output)
    end
  end

  describe '#rename_photos' do
    it 'renames photos with the new name format' do
      sorted_photos = {
        "Krakow" => [
          {
            index: 1,
            name: "myFriends",
            extension: "png",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:07:13', '%Y-%m-%d %H:%M:%S'),
          },
          {
            index: 0,
            name: "photo",
            extension: "jpg",
            city: "Krakow",
            date_time: DateTime.strptime('2013-09-05 14:08:15', '%Y-%m-%d %H:%M:%S'),
          },
        ],
      }

      expected_output = "Krakow2.jpg\nKrakow1.png"
      expect(photo_renamer_instance.rename_photos(sorted_photos)).to eq(expected_output)
    end
  end


  describe '#photo_renamer' do
    let(:input_string) do
      "photo.jpg, Krakow, 2013-09-05 14:08:15\n"\
      "Mike.png, London, 2015-06-20 15:13:22\n"\
      "myFriends.png, Krakow, 2013-09-05 14:07:13\n"\
      "Eiffel.jpg, Florianopolis, 2015-07-23 08:03:02\n"\
      "pisatower.jpg, Florianopolis, 2015-07-22 23:59:59\n"\
      "BOB.jpg, London, 2015-08-05 00:02:03\n"\
      "notredame.png, Florianopolis, 2015-09-01 12:00:00\n"\
      "me.jpg, Krakow, 2013-09-06 15:40:22\n"\
      "a.png, Krakow, 2016-02-13 13:33:50\n"\
      "b.jpg, Krakow, 2016-01-02 15:12:22\n"\
      "c.jpg, Krakow, 2016-01-02 14:34:30\n"\
      "d.jpg, Krakow, 2016-01-02 15:15:01\n"\
      "e.png, Krakow, 2016-01-02 09:49:09\n"\
      "f.png, Krakow, 2016-01-02 10:55:32\n"\
      "g.jpg, Krakow, 2016-02-29 22:13:11"
    end

    let(:expected_output) do
      "Krakow02.jpg\n"\
      "London1.png\n"\
      "Krakow01.png\n"\
      "Florianopolis2.jpg\n"\
      "Florianopolis1.jpg\n"\
      "London2.jpg\n"\
      "Florianopolis3.png\n"\
      "Krakow03.jpg\n"\
      "Krakow09.png\n"\
      "Krakow07.jpg\n"\
      "Krakow06.jpg\n"\
      "Krakow08.jpg\n"\
      "Krakow04.png\n"\
      "Krakow05.png\n"\
      "Krakow10.jpg"
    end

    it 'returns the correct output for the given input string' do
      expect(photo_renamer_instance.photo_renamer(input_string)).to eq(expected_output)
    end

  end
end