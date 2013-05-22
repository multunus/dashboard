require 'google_drive'

SCHEDULER.every '5m', :first_in => 0 do
  radiators = RadiatorReader.new().read_data
  radiators.keys.each do | project_name|
    send_event(project_name.downcase, {items: radiators[project_name]})
  end
end

