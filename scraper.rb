require 'scraperwiki'
require 'mechanize'
require 'json'

agent = Mechanize.new

viewurlbase = "https://eplanning.surfcoast.vic.gov.au/Public/ViewActivity.aspx?refid="

page = agent.post(
  "https://eplanning.surfcoast.vic.gov.au/Services/ReferenceService.svc/Get_PlanningRegister",
  {"packet"=>
    [{"name"=>"sEcho", "value"=>2},
     {"name"=>"iColumns", "value"=>8},
     {"name"=>"sColumns", "value"=>",,,,,,,"},
     {"name"=>"iDisplayStart", "value"=>0},
     {"name"=>"iDisplayLength", "value"=>10},
     {"name"=>"mDataProp_0", "value"=>"ApplicationReference"},
     {"name"=>"sSearch_0", "value"=>""},
     {"name"=>"bRegex_0", "value"=>false},
     {"name"=>"bSearchable_0", "value"=>true},
     {"name"=>"bSortable_0", "value"=>true},
     {"name"=>"mDataProp_1", "value"=>"LodgedDate_STRING"},
     {"name"=>"sSearch_1", "value"=>""},
     {"name"=>"bRegex_1", "value"=>false},
     {"name"=>"bSearchable_1", "value"=>true},
     {"name"=>"bSortable_1", "value"=>true},
     {"name"=>"mDataProp_2", "value"=>"DecisionDate_STRING"},
     {"name"=>"sSearch_2", "value"=>""},
     {"name"=>"bRegex_2", "value"=>false},
     {"name"=>"bSearchable_2", "value"=>true},
     {"name"=>"bSortable_2", "value"=>true},
     {"name"=>"mDataProp_3", "value"=>"SiteAddress"},
     {"name"=>"sSearch_3", "value"=>""},
     {"name"=>"bRegex_3", "value"=>false},
     {"name"=>"bSearchable_3", "value"=>true},
     {"name"=>"bSortable_3", "value"=>false},
     {"name"=>"mDataProp_4", "value"=>"ReasonForPermit"},
     {"name"=>"sSearch_4", "value"=>""},
     {"name"=>"bRegex_4", "value"=>false},
     {"name"=>"bSearchable_4", "value"=>true},
     {"name"=>"bSortable_4", "value"=>true},
     {"name"=>"mDataProp_5", "value"=>"Ward"},
     {"name"=>"sSearch_5", "value"=>""},
     {"name"=>"bRegex_5", "value"=>false},
     {"name"=>"bSearchable_5", "value"=>true},
     {"name"=>"bSortable_5", "value"=>true},
     {"name"=>"mDataProp_6", "value"=>"StatusName"},
     {"name"=>"sSearch_6", "value"=>""},
     {"name"=>"bRegex_6", "value"=>false},
     {"name"=>"bSearchable_6", "value"=>true},
     {"name"=>"bSortable_6", "value"=>false},
     {"name"=>"mDataProp_7", "value"=>"Actions"},
     {"name"=>"sSearch_7", "value"=>""},
     {"name"=>"bRegex_7", "value"=>false},
     {"name"=>"bSearchable_7", "value"=>true},
     {"name"=>"bSortable_7", "value"=>true},
     {"name"=>"sSearch", "value"=>""},
     {"name"=>"bRegex", "value"=>false},
     {"name"=>"iSortCol_0", "value"=>1},
     {"name"=>"sSortDir_0", "value"=>"desc"},
     {"name"=>"iSortingCols", "value"=>1},
     {"name"=>"sRangeSeparator", "value"=>"~"}]}.to_json,
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