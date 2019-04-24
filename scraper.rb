require 'scraperwiki'
require 'mechanize'

url = 'https://www.surfcoast.vic.gov.au/Property/Planning/View-applications-or-make-a-submission/Applications-on-public-exhibition'

agent = Mechanize.new
agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

page = agent.get url

page.at(:table).search(:tr).each_with_index do |r,i|
  next if i == 0 # Skip the first row header

  council_reference = r.search(:td)[0].inner_text.gsub(/\u00a0/,'')

  if (ScraperWiki.select("* from data where `council_reference`='#{council_reference}'").empty? rescue true)
    detail_page_url = r.at(:a).attr(:href)
    begin
      detail_page = agent.get detail_page_url
    rescue URI::InvalidURIError
      puts "DA #{council_reference} has a broken detail page, skipping"
      next
    end

    matches = r.search(:td)[3].inner_text.split(/\u00a0/)
    on_notice_from = ''
    on_notice_to = Date.parse(matches[1])

    record = {
      council_reference: council_reference,
      address: detail_page.at(:h1).inner_text.strip + ", VIC",
      on_notice_from: on_notice_from,
      on_notice_to: on_notice_to,
      description: detail_page.search('div.main-container').inner_text.split(/Proposal:(.*?)Permit No:/m)[1].gsub(/\u00a0/,'').strip,
      info_url: detail_page_url,
      comment_url: "planningapps@surfcoast.vic.gov.au",
      date_scraped: Date.today
    }

    puts "Saving record " + council_reference + ", " + record[:address]
#     puts record
    ScraperWiki.save_sqlite([:council_reference], record)
  else
    puts "Skipping already saved record " + council_reference
  end
end

