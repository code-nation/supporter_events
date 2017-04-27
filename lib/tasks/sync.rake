namespace :sync do

  desc 'Syncs everything'
  task :all => :environment do |t, args|
    Nation.all.each do |nation|
      sync_nation nation
    end
  end

  desc 'Syncs a specific nation'
  task :nation, [:nation_slug] => :environment do |t, args|
    nation = Nation.find_by_slug(args[:nation_slug])
    if nation
      sync_nation nation
    else
      error "Did not find nation with slug #{args[:nation_slug]}"
    end
  end

  desc 'Runs a specific action for a specific nation. Possible actions: sites, pages, sync, delete'
  task :run, [:nation_slug, :action] => :environment do |t, args|
    if action_exists? args[:action]
      nation = Nation.find_by_slug(args[:nation_slug])

      if nation

        if nation.is_connected_to_nb?
          include SyncHelper
          perform_action_for_nation args[:action], nation
        else
          error "Nation #{nation.slug} is not connected to NB, cannot sync!"
        end

      else
        error "Did not find nation with slug #{args[:nation_slug]}"
      end

    else
      error "Action #{args[:action]} does not exist. Please use sites, pages, sync or delete."
    end
  end

  private
  def sync_nation(nation)
    if nation.is_connected_to_nb?
      include SyncHelper

      info "Syncing #{nation.slug}"

      info 'Step 1: get all sites'
      get_all_sites nation

      info 'Step 2: get all event pages'
      get_all_event_pages nation

      info 'Step 3: sync all pending event pages'
      sync_all_pending_event_pages nation

      info 'Step 4: delete all pending event pages'
      delete_all_pending_event_pages nation
    else
      error "Nation #{nation.slug} is not connected to NB, cannot sync!"
    end
  end

  def perform_action_for_nation(action, nation)
    case action.to_sym
      when :sites
        info 'Get all sites'
        get_all_sites nation
      when :pages
        info 'Get all event pages'
        get_all_event_pages nation
      when :sync
        info 'Sync all pending event pages'
        sync_all_pending_event_pages nation
      when :delete
        info 'Delete all pending event pages'
        delete_all_pending_event_pages nation
      else
        error 'Nation found but no action was executed.'
    end
  end

  def action_exists?(action)
    [:sites, :pages, :sync, :delete].include? action.to_sym
  end

  # Logger helpers
  def info(message)
    @logger ||= Logger.new STDOUT
    @logger.info message
  end

  def error(message)
    @logger ||= Logger.new STDOUT
    @logger.error message
  end
end