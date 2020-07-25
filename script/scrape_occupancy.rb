#!/usr/bin/env ruby

require 'byebug'
require 'dotenv/load'
require 'json'
require 'logger'
require 'open-uri'
require 'nokogiri'
require 'sequel'

db_url      = ENV.fetch("BACKEND_DATABASE_URL")
data_uri    = ENV.fetch("DATA_URI")
DB          = Sequel.connect("#{db_url}")

logger            = Logger.new(STDOUT)
logger.level      = Logger::INFO

logger.info "Scrape Starting"

html = URI.open data_uri

doc = Nokogiri::HTML(html)

occupancy_string = doc.children[1].children[3].children[3].text.match(/var\s+data\s+=\s+(.*?)\;/m)[1]

occupancy = JSON.parse(occupancy_string.gsub("'", "\"").gsub(/\s+/, "").gsub("},}","}}"))

count = occupancy["AAA"]["count"]

timestamp = occupancy["AAA"]["lastUpdate"].match(/\((.*)\)/)[1]

class OccupancyCount < Sequel::Model
  plugin :timestamps, create: :created_at
end

OccupancyCount.create climber_count: count, created_at: Time.now.utc

logger.info "Scrape Complete"
