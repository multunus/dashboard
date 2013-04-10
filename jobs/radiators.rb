require 'google_drive'

SPREADSHEET_KEY = "0ApUPwJdQvqT_dDI0X3ZUSUFSSkFRa19oMEZUakVDZGc"

SCHEDULER.every '2s' do
  session = GoogleDrive.login(ENV['USER_NAME'],ENV['PASSWORD'])
  worksheets = session.spreadsheet_by_key(SPREADSHEET_KEY).worksheets
  radiators = read_data_as_array_from_doc(worksheets)
  radiators.keys.each do | project_name|
    send_event(project_name.downcase, radiators[project_name])
    #send_event(item[:project_name].downcase, { org_radiator_items: item[:org_radiator_items]})
  end
end

def read_data_as_array_from_doc(worksheets)
  item_names = ["org_radiator_items","tech_radiator_items","personal_radiator_items"]
  project_radiator_data = {}
  for item in 0..2
    doc = worksheets[item]
    for row in 2..doc.num_rows
      data = []
      project_name = doc[row,1] 
      for col in 2..doc.num_cols
        data << {label: doc[1,col],class: "label-#{doc[row,col].downcase}"}  
      end

      if(project_radiator_data[project_name])
        project_radiator_data[project_name].merge!({item_names[item] => data})
      else
        project_radiator_data[project_name] = {item_names[item] => data}
      end
    end
  end
  project_radiator_data
end
