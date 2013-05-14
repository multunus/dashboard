require "spec_helper"
require 'radiator_reader'

describe RadiatorReader do
  use_vcr_cassette
  RadiatorReader::SPREADSHEET_KEYS = ["0ApUPwJdQvqT_dDI0X3ZUSUFSSkFRa19oMEZUakVDZGc"]

  describe "Read Radiator Data from a Google SpreadSheet(s)" do
    it "should return data with project name as key and the items hash" do
      radiator_data =  {"Narrable"=>[{:label=>"Delivery Schedule", :modified_date=>"", :class=>"label-"}, {:label=>"Objective Quality", :class=>"label-no", :modified_date=>"Organization"}, {:label=>"User Experience", :class=>"label-yes", :modified_date=>"Organization"}, {:label=>"No of Deployments", :class=>"label-yes", :modified_date=>"Organization"}]}
      RadiatorReader.new.read_data.should eql radiator_data
    end
  end
end
