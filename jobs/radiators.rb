require 'google_drive'

SPREADSHEET_KEYS = ["0Am5kxIePmFmbdFBrWElZZW5jZVQwODRpRXNsMEFWRkE",
                    "0Agj1177vtu0MdGI2OVVWcXhUYTNtTDl4SFM2djlESXc",
                    "0Agj1177vtu0MdElYdnZpb0ctaERXN2VnVmRmR3g3REE"]

SCHEDULER.every '5s' do
  radiators = RadiatorReader.new().read_data
  radiators.keys.each do | project_name|
    send_event(project_name.downcase, {items: radiators[project_name]})
  end
end

class RadiatorReader
  @@session = GoogleDrive.login(ENV['USER_NAME'],ENV['PASSWORD'])
  def initialize
    @project_radiator_data = {}
  end

  def read_data
    for item in 0..SPREADSHEET_KEYS.size - 1
      doc = @@session.spreadsheet_by_key(SPREADSHEET_KEYS[item]).worksheets[0]
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
    data = fetch_data_if_exists_for_project_to_append_more_data(project_name)
    for col in 2..doc.num_cols
      data << {label: doc[1,col],class: "label-#{doc[row,col].downcase}"}  
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
