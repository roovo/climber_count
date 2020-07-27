#!/usr/bin/env ruby

require 'csv'
require 'dotenv/load'
require 'json'
require 'logger'
require 'open-uri'
require 'nokogiri'
require 'net/ssh'
require 'net/scp'

LOGGER          = Logger.new(STDOUT)
LOGGER.level    = Logger::INFO

@time           = Time.now

buffer          = 15 * 60             #  seconds

WEEKEND_OPEN    = (Time.parse "10:00") - buffer
WEEKEND_CLOSE   = (Time.parse "18:00") + buffer

WEEKDAY_OPEN    = (Time.parse "12:00") - buffer
WEEKDAY_CLOSE   = (Time.parse "21:30") + buffer

DATA_URI        = ENV.fetch("DATA_URI")
UPLOAD_IP       = ENV.fetch("UPLOAD_IP")
UPLOAD_PORT     = ENV.fetch("UPLOAD_PORT")
UPLOAD_PATH     = ENV.fetch("UPLOAD_PATH")
UPLOAD_USER     = ENV.fetch("UPLOAD_USER")
KEY_PATH        = ENV.fetch("KEY_PATH")

def during_weekend_opening
  if @time.saturday? || @time.sunday?
    if (@time >= WEEKEND_OPEN) && (@time <= WEEKEND_CLOSE)
      true
    else
      false
    end
  else
    false
  end
end

def during_weekday_opening
  if @time.saturday? || @time.sunday?
    false
  else
    if (@time >= WEEKDAY_OPEN) && (@time <= WEEKDAY_CLOSE)
      true
    else
      false
    end
  end
end

def is_on_the_hour?
  @time.min.zero?
end

def write_count(count)
  LOGGER.info "Updating count: #{count}"

  CSV.open("./data/climber_count.csv", "a") do |csv|
    csv << [Time.now.utc.to_s.gsub(" UTC", "Z").gsub(" ", "T"), count.to_s]
  end

  Net::SCP.start(UPLOAD_IP, UPLOAD_USER, port: UPLOAD_PORT, keys: [KEY_PATH]) do |ssh|
    ssh.upload! "./data/climber_count.csv", UPLOAD_PATH
  end
end

if during_weekend_opening || during_weekday_opening

  LOGGER.info "Scrape Starting"

  html = URI.open DATA_URI

  doc = Nokogiri::HTML(html)

  occupancy_string  = doc.children[1].children[3].children[3].text.match(/var\s+data\s+=\s+(.*?)\;/m)[1]
  occupancy         = JSON.parse(occupancy_string.gsub("'", "\"").gsub(/\s+/, "").gsub("},}","}}"))
  count             = occupancy["AAA"]["count"]

  write_count(count)

  LOGGER.info "Scrape Complete"
else
  LOGGER.info "No Scrape: Gym Closed"

  if is_on_the_hour?
    write_count(0)
  end

  LOGGER.info "Update Complete"
end

