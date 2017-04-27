require 'csv'
require 'roo'

module EventsHelper

	# This will create the event from the data in the spreadsheet
	def nb_import_events(data, import)
		event_params = build_import_events(data)
		client = primary_nation_nb_client
	    params = {
        site_slug: ENV['PRIMARY_NATION_SITE_SLUG'],
        event: event_params
      }
	    if params[:event][:status] == 500
			import.import_logs.create(row: data[:row], status: params[:event][:status], message: params[:event][:message])
	    else
	    	response = client.call(:events, :create, params)
	    	import.import_logs.create(row: data[:row], status: response['status_code'], message: 'Imported')
	    end
	end

	private
		# This will map the spreadsheet data and build the necessary JSON format
    # See all event options here: http://nationbuilder.com/event_resource
  	def build_import_events(data)
  		begin
  			Time.zone = ENV['DEFAULT_TIME_ZONE']
  			start_date = Date.parse(data[:event]['start_date'])
  			start_time = Time.zone.parse(data[:event]['start_time'])
	  		{
	        calendar_id: ENV['PRIMARY_NATION_CALENDAR_ID'].to_i,
	        status: data[:event]['status'],
	        # Optionally restrict which tags are imported
	        tags: build_import_event_tags(data[:event]['tags']),
	        name: data[:event]['name'],
	        headline: data[:event]['headline'],
	        # Optionally use the excerpt field to store a URL if you wish to redirect
	        # users to an external event page directly from your calendar. Make sure
	        # to also change {{ event.url }} to {{ event.excerpt }} in your theme's
	        # calendar template.
	        excerpt: data[:event]['excerpt'],
	        intro: data[:event]['intro'],
	        # The build_event_contact method only adds the contact if name and email exist:
	        # this is a restriction imposed by the NationBuilder API
	        contact: build_event_contact(data),
	        start_time: get_start_time(start_date, start_time),
	        end_time: get_end_time(start_date, start_time, data[:event]['duration']),
	        venue: {
	            name: data[:event]['venue_name'],
	            address: {
	                address1: data[:event]['address1'],
	                city: data[:event]['city'],
	                state: data[:event]['state'],
	                zip: data[:event]['zip']
	            }
	        },
	        # A capacity value of 0 creates the event with an unlimited capacity
	        capacity: 0,
	        # Choose appropriate rsvp_form settings below
	        rsvp_form: {
	            phone: "hidden",
	            address: "hidden",
	            allow_guests: true,
	            accept_rsvps: true,
	            gather_volunteers: false
	        },
	        # Optionally set values for the `autoresponse` and `shifts` attributes
	        show_guests: true
	    	}
  		rescue ArgumentError, TypeError => error
  			error = error.message
  			if error == 'no implicit conversion of nil into String'
  				error = "Start date/time can't be blank"
  			elsif error == 'invalid date'
  				error = "Start date is invalid format"
  			end
				{
					message: "#{error}",
					status: 500
				}
			end
	  end
	  	
		def get_start_time(start_date, start_time)
		  Time.zone = ENV['DEFAULT_TIME_ZONE']
		  Time.zone.parse("#{start_date.to_s} #{start_time.to_s}").iso8601
		end

		def get_end_time(start_date, start_time, duration)
			event_duration = duration.nil? ? ENV['DEFAULT_EVENT_DURATION'] : duration
			Time.zone = ENV['DEFAULT_TIME_ZONE']
			build_end_time = (Time.zone.parse(get_start_time(start_date, start_time)) + event_duration.to_i.send('minutes')).iso8601
		end

  	# This will join the tags from the IMPORT_EVENT_TAGS
  	# environment variable with the tags from the spreadsheet
		def build_import_event_tags(tags)
			tags = tags.split(',').map{ |tag| tag.strip } << ENV['IMPORT_EVENT_TAGS'].split(',').map{ |tag| tag.strip }
			tags.flatten
		end

		def build_event_contact(data)
			if data[:event]['contact_full_name'].nil? || data[:event]['contact_email'].nil?
				nil
			else
				{
          name: data[:event]['contact_full_name'].strip,
          phone: data[:event]['contact_phone_number'].strip,
          show_phone: true,
          email: data[:event]['contact_email'].strip,
          show_email: true
      	}
			end
		end
end
