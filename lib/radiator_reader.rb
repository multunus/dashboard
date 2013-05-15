require 'google_drive'
require_relative 'google_drive_session'

class RadiatorReader
  SPREADSHEET_KEYS = ["0Am5kxIePmFmbdFBrWElZZW5jZVQwODRpRXNsMEFWRkE",
                      "0Agj1177vtu0MdGI2OVVWcXhUYTNtTDl4SFM2djlESXc","0Agj1177vtu0MdElYdnZpb0ctaERXN2VnVmRmR3g3REE"]

  PROGRESS_SPREADSHEET_KEYS = {
    "menume" => "0ArY8tIav5XnMdFNSV2hJQXlCNG94cUdUZnBGTkhrbWc",
    "narrable" => "0Amkau_yET23PdFNzQ2NZY1FMUV93WnVhMmd3QkxIWmc",
    "tims" => "0AurK0h8yI6n6dGJVNm13Q2tQUUI2VXBCTzdVMDVMRUE"
  }
  
  def initialize
    @project_radiator_data = {}
    @session = GoogleDriveSession.instance.session
  end

  def read_data
    for item in 0..SPREADSHEET_KEYS.size - 1
      doc = @session.spreadsheet_by_key(SPREADSHEET_KEYS[item]).worksheets[0]
      read_each_project_data_as_row(doc)
    end
    @project_radiator_data
  end

  private
  
  def read_each_project_data_as_row(doc)
    for row in 2..doc.num_rows
      append_radiator_data_for_given_project_row(doc,row)
    end
  end

  def append_radiator_data_for_given_project_row(doc,row)
    project_name = doc[row,1]
    delivery_schedule_data = {:pt_status => "", :status => ""}
    progress_spreadsheet_key = PROGRESS_SPREADSHEET_KEYS[project_name.downcase]
    delivery_schedule_data = fetch_delivery_schedule_data_for_project project_name unless progress_spreadsheet_key.nil?
    puts delivery_schedule_data
    data = fetch_data_if_exists_for_project_to_append_more_data(project_name)
    for col in 2..doc.num_cols
      add_radiator_data(data, doc, row, col,  delivery_schedule_data)
    end
  end

  def add_radiator_data(data, doc, row, col,  delivery_schedule_data)
    if doc[1, col].downcase == "Delivery Schedule".downcase
      data << {label: doc[1,col], progress_track_updated_status_class: "progress-track-updated-#{delivery_schedule_data[:pt_status]}", class: "label-#{delivery_schedule_data[:status].downcase}"}
    else
      data << {label: doc[1,col], progress_track_updated_status_class: "progress-track-updated-yes", class: "label-#{doc[row,col].downcase}"}
    end
  end

  def fetch_delivery_schedule_data_for_project(project_name)
    begin
      doc = @session.spreadsheet_by_key(PROGRESS_SPREADSHEET_KEYS[project_name.downcase]).worksheets[0]
      last_modified_date_row = 2
      {:pt_status => progress_track_updated_status(format_progress_track_updated_date(doc[last_modified_date_row, 1])), :status => doc[last_modified_date_row, 2]}
    rescue Exception => e
      delivery_schedule_data = {:pt_status => "", :status => ""}
    end
  end

  def format_progress_track_updated_date(progress_track_updated_date)
    Date.strptime(progress_track_updated_date, "%m/%d/%y").strftime("%b-%d")
  end

  def format_radiator_updated_date(radiator_updated_date)
    Date.strptime(radiator_updated_date, "%m/%d/%y").strftime("%b %dth")
  end

  def progress_track_updated_status(progress_track_updated_date)
    today_date = Date.today.to_s
    progress_track_updated_status =  "yes"
    progress_track_updated_status =  "no" if (DateTime.parse(today_date) - DateTime.parse(progress_track_updated_date)).to_i > 1
    progress_track_updated_status
  end

  def radiator_updated_status(radiator_updated_date)
  end

  def fetch_data_if_exists_for_project_to_append_more_data(project_name)
    data = @project_radiator_data[project_name]
    if data.nil?
      data = [] if data.nil?
      @project_radiator_data[project_name] = data
    end
    data
  end
end
