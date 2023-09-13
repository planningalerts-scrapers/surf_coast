require 'scraperwiki'
require 'mechanize'
require 'json'

def scrape_api(url:, start:, length:)
  agent = Mechanize.new

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
    {"Content-type" => "application/json"}
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
      'info_url' => "#{url}/Public/ViewActivity.aspx?refid=#{URI.encode(council_reference)}",
      'date_scraped' => Date.today.to_s,
      'date_received' => Date.strptime(r['LodgedDate_STRING'], "%d-%b-%Y").to_s
    }
  end  
end

# Get all applications that were received on or after the start date
def scrape_api_with_paging(url:, start_date:)
  max_per_request = 10

  start = 0
  loop do
    results = scrape_api(url: url, start: start, length: max_per_request)
    results.each do |r|
      yield r if Date.parse(r["date_received"]) >= start_date
    end
    break if results.any? { |r| Date.parse(r["date_received"]) < start_date }
    start += max_per_request
  end
end

# Get data from the last 28 days
scrape_api_with_paging(url: "https://eplanning.surfcoast.vic.gov.au", start_date: Date.today - 28) do |record|
  pp record
end