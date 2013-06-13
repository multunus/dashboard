require 'google_drive'
require_relative 'google_drive_session'

class RadiatorReader
  SPREADSHEET_KEYS = ["0Am5kxIePmFmbdFBrWElZZW5jZVQwODRpRXNsMEFWRkE",
                      "0Agj1177vtu0MdGI2OVVWcXhUYTNtTDl4SFM2djlESXc","0Agj1177vtu0MdElYdnZpb0ctaERXN2VnVmRmR3g3REE"]

  PROGRESS_SPREADSHEET_KEYS = {
    "menume" => "0ArY8tIav5XnMdFNSV2hJQXlCNG94cUdUZnBGTkhrbWc",
    "narrable" => "0Amkau_yET23PdFNzQ2NZY1FMUV93WnVhMmd3QkxIWmc"
  }

  PROGRESS_TRACK_UPDATE_FREQUENCY_IN_DAYS = 1
  RADIATORS_UPDATE_FREQUENCY_IN_DAYS = 7

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
    delivery_schedule_data = {:pt_status => "hide", :status => ""}
    progress_spreadsheet_key = PROGRESS_SPREADSHEET_KEYS[project_name.downcase]
    delivery_schedule_data = fetch_delivery_schedule_data_for_project project_name unless progress_spreadsheet_key.nil?
    radiator_updated_status = get_radiator_updated_status(doc.title)
    data = fetch_data_if_exists_for_project_to_append_more_data(project_name)
    for col in 2..doc.num_cols
      add_radiator_data(data, doc, row, col,  delivery_schedule_data, radiator_updated_status)
    end
  end

  def add_radiator_data(data, doc, row, col,  delivery_schedule_data, radiator_updated_status)
    if doc[1, col].downcase == "Delivery Schedule".downcase
      data << {label: doc[1,col], progress_track_updated_status_class: "angry-icon-#{delivery_schedule_data[:pt_status]}", class: "label-#{delivery_schedule_data[:status].downcase}"}
    else
      data << {label: doc[1,col], progress_track_updated_status_class: "angry-icon-#{radiator_updated_status}", class: "label-#{doc[row,col].downcase}"}
    end
  end

  def fetch_delivery_schedule_data_for_project(project_name)
    begin
      doc = @session.spreadsheet_by_key(PROGRESS_SPREADSHEET_KEYS[project_name.downcase]).worksheets[0]
      last_modified_date_row = 2
      {:pt_status => get_updated_status(doc[last_modified_date_row, PROGRESS_TRACK_UPDATE_FREQUENCY_IN_DAYS], 1), :status => doc[last_modified_date_row, 2]}
    rescue Exception => e
      delivery_schedule_data = {:pt_status => "hide", :status => ""}
    end
  end

  def get_radiator_updated_status(date)
    d = date.gsub( /.{2}$/, '' )
    date_month_format = d.gsub(/\s+/, '-')
    formated_date = Date.strptime(date_month_format, "%b-%d").strftime("%m/%d/%Y")
    get_updated_status(formated_date, RADIATORS_UPDATE_FREQUENCY_IN_DAYS)
  end

  def get_updated_status(updated_date, update_frequency_in_days)
    formated_date = Date.strptime(updated_date, "%m/%d/%Y").strftime("%b-%d")
    todays_date = Date.today.to_s
    if(Date.today.wday == 1) 
      modified_todays_date = DateTime.now.to_date - 2
      (DateTime.parse(modified_todays_date.to_s) - DateTime.parse(formated_date)).to_i > update_frequency_in_days ? "show" : "hide" 
    else
      (DateTime.parse(todays_date) - DateTime.parse(formated_date)).to_i > update_frequency_in_days ? "show" : "hide" 
    end
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
