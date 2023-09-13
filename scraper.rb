require 'scraperwiki'
require 'mechanize'
require 'json'

agent = Mechanize.new

viewurlbase = "https://eplanning.surfcoast.vic.gov.au/Public/ViewActivity.aspx?refid="

page = agent.post(
  "https://eplanning.surfcoast.vic.gov.au/Services/ReferenceService.svc/Get_PlanningRegister",
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
  record = {
    'council_reference' => r['ApplicationReference'].strip,
    'address' => r['SiteAddress'],
    # TODO: I wonder if description should also include "Proposal Type"?
    'description' => r['ReasonForPermit'],
    'info_url' => (viewurlbase + URI.encode(r['ApplicationReference'])).to_s,
    'date_scraped' => Date.today.to_s,
    'date_received' => Date.strptime(r['LodgedDate_STRING'], "%d-%b-%Y").to_s
  }
  pp record
end