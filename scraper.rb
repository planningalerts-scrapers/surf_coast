require 'scraperwiki'
require 'mechanize'
require 'json'

agent = Mechanize.new

url = "https://eplanning.surfcoast.vic.gov.au"

page = agent.post(
  "#{url}/Services/ReferenceService.svc/Get_PlanningRegister",
  { "packet" =>
    [
      { "name" => "iDisplayStart", "value" => 0 },
      { "name" => "iDisplayLength", "value" => 10 },
      { "name" => "iSortCol_0", "value" => 1 },
      { "name" => "sSortDir_0", "value" => "desc" }
    ]
  }.to_json,
  {"Content-type" => "application/json"}
)
result = JSON.parse(page.body)
d = JSON.parse(result["d"])

av = d["ActivityView"]
# TODO: Add support for paging
# TODO: Only get applications in a particular date range
av.each do |r|
  council_reference = r['ApplicationReference'].strip
  record = {
    'council_reference' => council_reference,
    'address' => r['SiteAddress'],
    'description' => r['ReasonForPermit'],
    'info_url' => "#{url}/Public/ViewActivity.aspx?refid=#{URI.encode(council_reference)}",
    'date_scraped' => Date.today.to_s,
    'date_received' => Date.strptime(r['LodgedDate_STRING'], "%d-%b-%Y").to_s
  }
  pp record
end