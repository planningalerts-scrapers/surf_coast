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

# TODO: Add support for paging
# TODO: Only get applications in a particular date range
result = scrape_api(url: "https://eplanning.surfcoast.vic.gov.au", start: 0, length: 10)

pp result