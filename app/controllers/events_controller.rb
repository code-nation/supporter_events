class EventsController < ApplicationController
  load_and_authorize_resource :class => "Import"
  include NationsHelper, SyncHelper, EventsHelper
  
  FILE_EXTENSION = ['.csv', '.xls', '.xlsx']

  def index
  end

  def imports
  end
  
  def import
    if params[:event].nil?
      redirect_to imports_events_path, alert: "No uploaded CSV or Excel file." 
    else
      file_extension = File.extname(params[:event].original_filename)

      if FILE_EXTENSION.include?(file_extension)
        import = Import.create(name: params[:event].original_filename, import_type: 'events')
        spreadsheet = open_spreadsheet(file_extension, params[:event])
        header = spreadsheet.row(1)
        events = (2..spreadsheet.last_row).map { |i| { event: Hash[[header, spreadsheet.row(i)].transpose], row: i } }
        
        events.each do |event|
          nb_import_events(event, import)
        end
        redirect_to imported_log_events_path(import), notice: "You have successfully imported those events. Please check your NationBuilder calendar."
      else
        redirect_to imports_events_path, alert: "Unknown file type: #{params[:event].original_filename}"
      end
    end
  end

  def imported
    @imported = Import.order(created_at: :desc)
  end

  def logs
    @import = Import.find(params[:id])
    @import_logs = @import.import_logs
  end

  private
    def open_spreadsheet(file_extension, file)
      if file_extension == '.csv'
        Roo::CSV.new(file.path)
      elsif file_extension == '.xls'
        Roo::Excel.new(file.path)
      else file_extension == '.xlsx'
        Roo::Excelx.new(file.path)
      end
    end
end
