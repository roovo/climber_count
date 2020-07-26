#!/usr/bin/env ruby

require 'csv'
require 'dotenv/load'
require 'json'
require 'logger'
require 'open-uri'
require 'nokogiri'
require 'net/ssh'
require 'net/scp'

logger            = Logger.new(STDOUT)
logger.level      = Logger::INFO

time = Time.now

def during_weekend_opening(time)
  if time.saturday? || time.sunday?
    if (time.hour < 10 && time.min < 30) || (time.hour >= 18 && time.min > 30)
      false
    else
      true
    end
  else
    false
  end
end

def during_weekday_opening(time)
  if time.saturday? || time.sunday?
    false
  else
    if (time.hour < 12 && time.min < 30) || (time.hour >= 22 && time.min > 0)
      false
    else
      true
    end
  end
end

if during_weekend_opening(time) || during_weekday_opening(time)
  data_uri    = ENV.fetch("DATA_URI")
  upload_ip   = ENV.fetch("UPLOAD_IP")
  upload_port = ENV.fetch("UPLOAD_PORT")
  upload_path = ENV.fetch("UPLOAD_PATH")
  upload_user = ENV.fetch("UPLOAD_USER")
  key_path    = ENV.fetch("KEY_PATH")

  logger.info "Scrape Starting"

  html = URI.open data_uri

  doc = Nokogiri::HTML(html)

  occupancy_string  = doc.children[1].children[3].children[3].text.match(/var\s+data\s+=\s+(.*?)\;/m)[1]
  occupancy         = JSON.parse(occupancy_string.gsub("'", "\"").gsub(/\s+/, "").gsub("},}","}}"))
  count             = occupancy["AAA"]["count"]

  logger.info "Updating CSV"

  CSV.open("./data/climber_count.csv", "a") do |csv|
    csv << [Time.now.utc.to_s.gsub(" UTC", "Z").gsub(" ", "T"), count.to_s]
  end

  logger.info "Uploading CSV"

  Net::SCP.start(upload_ip, upload_user, port: upload_port, keys: [key_path]) do |ssh|
    ssh.upload! "./data/climber_count.csv", upload_path
  end

  logger.info "Scrape Complete"
else
  logger.info "No scrape: gym closed"
end
