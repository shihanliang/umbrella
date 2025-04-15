# Write your solution below!
require "http"
require "json"
require "dotenv/load"

line_width = 40

puts "=" * line_width
puts "Do you need an umbrella today?".center(line_width)
puts "=" * line_width
puts

print "Enter your location: "
location = gets.chomp

puts "Looking up weather info for #{location}..."

gmaps_api_key = ENV.fetch("GMAPS_KEY")
gmaps_api_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_api_key}"

gmaps_response = HTTP.get(gmaps_api_url)
gmaps_data = JSON.parse(gmaps_response)

coordinates = gmaps_data.dig("results", 0, "geometry", "location")
lat = coordinates["lat"]
lng = coordinates["lng"]

puts "Coordinates found: #{lat}, #{lng}"

weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
weather_url = "https://api.pirateweather.net/forecast/#{weather_key}/#{lat},#{lng}"

weather_response = HTTP.get(weather_url)
weather_data = JSON.parse(weather_response)

current_temp = weather_data.dig("currently", "temperature")
puts "Current temperature: #{current_temp}°F"

if weather_data.key?("minutely")
  puts "Next hour: #{weather_data.dig("minutely", "summary")}"
end

upcoming_hours = weather_data.dig("hourly", "data")[1..12]
rain_warning = false

upcoming_hours.each do |hour|
  chance_of_rain = hour["precipProbability"]

  if chance_of_rain > 0.10
    rain_warning = true
    time_of_rain = Time.at(hour["time"])
    hours_until = ((time_of_rain - Time.now) / 3600).round

    puts "Chance of rain in #{hours_until} hour(s): #{(chance_of_rain * 100).round}%"
  end
end

puts rain_warning ? "Better bring an umbrella" : "No umbrella needed today"
