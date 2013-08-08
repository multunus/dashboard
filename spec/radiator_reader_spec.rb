require "spec_helper"
require 'project_radiator_reader'
require 'active_support/all'

describe ProjectRadiatorReader do
  context("ProjectRadiatorReader") do
    before(:all) do
      load_test_spreadsheets
      @data_reader = ProjectRadiatorReader.new
      @data_reader.fetch
      @project_raditors = ["Objective Quality", "User Experience", "Deployments", "GPA Score", "Pairing", "Security & Performance", "Community Involvement", "Delivery Schedule"]
      @projects = ["Narrable", "MenuMe", "TIMS"]
    end

    it "should have the spreadsheet keys" do
      ProjectRadiatorReader::config.should have_key(:project_radiator_key)
      ProjectRadiatorReader::config.should have_key(:progress_tracker_keys)
    end

    it "should fetch all the projects" do
      @data_reader.projects.count.should == 3
      @data_reader.projects.collect(&:name).should == @projects
    end

    it "should fetch projects with radiator items" do
      project = @data_reader.projects.first
      project.radiator_items.collect(&:name).should ==  @project_raditors
    end

    it "should return the widget data" do
      narrable_expected_widget_data = [
                                       {:label=> "Objective Quality", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "User Experience", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "Deployments", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "GPA Score", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "Pairing", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "Security & Performance", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=> "Community Involvement", :progress_track_updated_status_class=>"angry-icon-show", :class=>"label-yes"},
                                       {:label=>"Delivery Schedule", :class=>"label-yes",:progress_track_updated_status_class=>"angry-icon-show"}
                                      ]
      @data_reader.projects.to_widget_data['Narrable'].should ==  narrable_expected_widget_data
    end

  end

end

describe Project do
  before(:all) do
    radiators = Array RadiatorItem.new("Objective Quality", "Yes", DateTime.now.to_date.strftime("%m/%d/%Y"))
    @project = Project.new("Narrable", radiators)
  end

  it "should convert to widget data" do
    @project.to_widget_data.should == {
      "Narrable" => [
                     {:label=> "Objective Quality", :progress_track_updated_status_class=>"angry-icon-hide", :class=>"label-yes"}
                    ]
    }

  end

end

describe RadiatorItem do
  before(:all) do
    #DateTime.should_receive(:now) { Date.parse("17-Jun-2013") }
    @radiator_item = RadiatorItem.new("Objective Quality", "Yes", DateTime.now.to_date.strftime("%m/%d/%Y"))
  end

  it "should convert to widget data" do
    @radiator_item.to_widget_data.should == {:label=> "Objective Quality", :progress_track_updated_status_class=>"angry-icon-hide", :class=>"label-yes"}
  end

  it "should be recently updated if last update date is less than 4 working days" do
    RadiatorItem.new("Objective Quality", "Yes", 12.days.ago).should_not be_updated_recently
    RadiatorItem.new("Objective Quality", "Yes", 1.days.ago).should be_updated_recently
  end

  it "should be recently updated if last updated date is less than 2 working days and it is the delivery schedule" do
    RadiatorItem.new("Delivery Schedule", "Yes", 3.days.ago).should_not be_updated_recently
    RadiatorItem.new("Delivery Schedule", "Yes", 1.days.ago).should be_updated_recently
  end

  it "should be red if there is no data" do
    RadiatorItem.new("Objective Quality", nil, nil).to_widget_data[:class].should == "label-no"
  end

  it "should return nil for last_updated if the date entered is wrong" do
    RadiatorItem.new("Delivery Schedule", "Yes", "Aug -6").should_not be_updated_recently
  end

end
