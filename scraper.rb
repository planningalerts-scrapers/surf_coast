#!/usr/bin/env ruby

require 'bundler/setup'

require 'cgi'
require 'json'
require 'mechanize'
require 'scraperwiki'

class Scraper
  def self.scrape_api(url:, start:, length:)
    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

    if ENV["MORPH_AUSTRALIAN_PROXY"]
      # On morph.io set the environment variable MORPH_AUSTRALIAN_PROXY to
      # http://morph:password@au.proxy.oaf.org.au:8888 replacing password with
      # the real password.
      puts "Using Australian proxy..."
      agent.agent.set_proxy(ENV["MORPH_AUSTRALIAN_PROXY"])
    end

    page = agent.post(
      "#{url}/Services/ReferenceService.svc/Get_PlanningRegister",
      { "packet" =>
          [
            { "name" => "iDisplayStart", "value" => start },
            { "name" => "iDisplayLength", "value" => length },
            { "name" => "iSortCol_0", "value" => 1 },
            { "name" => "sSortDir_0", "value" => "desc" }
          ]
      }.to_json,
      { "Content-type" => "application/json" }
    )
    result = JSON.parse(page.body)
    d = JSON.parse(result["d"])

    av = d["ActivityView"]
    av.map do |r|
      council_reference = r['ApplicationReference'].strip
      {
        'council_reference' => council_reference,
        'address' => r['SiteAddress'],
        'description' => r['ReasonForPermit'],
        'info_url' => "#{url}/Public/ViewActivity.aspx?refid=#{CGI.escapeURIComponent(council_reference)}",
        'date_scraped' => Date.today.to_s,
        'date_received' => Date.strptime(r['LodgedDate_STRING'], "%d-%b-%Y").to_s
      }
    end
  end

  # Get all applications that were received on or after the start date
  def self.scrape_api_with_paging(url:, start_date:)
    max_per_request = 10

    start = 0
    loop do
      puts "Requesting pageful of details ..."
      results = scrape_api(url: url, start: start, length: max_per_request)
      results.each do |r|
        yield r if Date.parse(r["date_received"]) >= start_date
      end
      break if results.any? { |r| Date.parse(r["date_received"]) < start_date }
      start += max_per_request
    end
  end

  # Get data from the last 30 days
  def self.run
    count = 0
    scrape_api_with_paging(url: "https://eplanning.surfcoast.vic.gov.au", start_date: Date.today - 30) do |record|
      puts "Storing #{record['council_reference']} - #{record['address']}"
      ScraperWiki.save_sqlite(['council_reference'], record)
      count += 1
    end
    puts "Finished - processed #{count} records"
  end
end

Scraper.run if __FILE__ == $PROGRAM_NAME

