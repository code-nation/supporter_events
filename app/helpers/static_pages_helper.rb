module StaticPagesHelper

  def alert_class(flash_key)
    case flash_key
      when 'notice'
        'alert-info'
      when 'alert'
        'alert-warning'
      when 'warning'
        'alert-warning'
      when 'error'
        'alert-danger'
      when 'success'
        'alert-success'
      else
        'alert-info'
    end
  end

end
