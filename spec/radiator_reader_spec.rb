require "spec_helper"
require 'radiator_reader'

describe RadiatorReader do
  use_vcr_cassette
  RadiatorReader::SPREADSHEET_KEYS = ["0ApUPwJdQvqT_dDI0X3ZUSUFSSkFRa19oMEZUakVDZGc"]

  describe "Read Radiator Data from a Google SpreadSheet(s)" do
    expected_data =     
    it "should return data with project name as key and the items hash" do
      radiator_data = {"Narrable"=>[{:label=>"Delivery Schedule", :class=>"label-yes"}, {:label=>"Objective Quality", :class=>"label-no"}, {:label=>"User Experience", :class=>"label-yes"}, {:label=>"No of Deployments", :class=>"label-yes"}]}
      RadiatorReader.new.read_data.should eql radiator_data
    end
  end
end
