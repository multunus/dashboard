require 'google_drive'
require_relative 'google_drive_session'
require_relative 'project'
require_relative 'radiator_item'

class ProjectRadiatorReader
  attr_accessor :projects

  class << self
    attr_accessor :config 
  end

  @config = {
    :project_radiator_key => "0An7HDRra1JxidHFxRTJ6YzlOM0RJMEtMX1lIZ2xfdXc",
    :progress_tracker_keys => {
      "MenuMe" => "0ArY8tIav5XnMdFNSV2hJQXlCNG94cUdUZnBGTkhrbWc",
      "Narrable" => "0Amkau_yET23PdFNzQ2NZY1FMUV93WnVhMmd3QkxIWmc",
      "CMH" => "0Amkau_yET23PdFRsNlBoVXpGeE12UjBHbXdzMHJodmc",
      "SW" => "0An7HDRra1JxidE1uRU84VEhTaXhsWFItY3pQYW14SUE"
    }
  }

  def initialize
    @session = GoogleDriveSession.instance.session
  end

  def fetch
    open_google_spreadsheet
    @projects = @radiator_doc.worksheets.collect do |worksheet|
      radiator_items = radiator_items_from(worksheet) + Array(progress_radiator_item(worksheet.title))
      Project.new(worksheet.title, radiator_items)
    end
  end

  def projects
    unless @projects.respond_to?(:to_widget_data)
      define_custome_method_in_projects_collection
    end
    @projects
  end

  private

  def progress_radiator_item(project_name)
    project_progress_tracker_key = self.class.config[:progress_tracker_keys][project_name]
    if project_progress_tracker_key
      doc = @session.spreadsheet_by_key(project_progress_tracker_key).worksheets[0] 
      RadiatorItem.new *["Delivery Schedule",doc[2,2],doc[2,1]]
    else
      RadiatorItem.new *["Delivery Schedule", '', '']
    end
  end

  def define_custome_method_in_projects_collection
    @projects.define_singleton_method(:to_widget_data) do
      results = collect(&:to_widget_data).inject({}) do |result, project_hash|
        result.merge(project_hash)
      end
    end
  end

  def open_google_spreadsheet
    @radiator_doc = @session.spreadsheet_by_key(self.class.config[:project_radiator_key])
  end

  def radiator_items_from(worksheet)
    project_records = worksheet.rows.dup
    project_records.collect{|record| RadiatorItem.new *record }
  end
  
end
