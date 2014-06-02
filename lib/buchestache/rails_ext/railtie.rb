require 'buchestache/middleware'

class Buchestache
  class Railtie < ::Rails::Railtie
    config.buchestache = ActiveSupport::OrderedOptions.new

    initializer 'buchestache.configure' do |app|
      if app.config.buchestache[:enabled]
        Buchestache.configure!(app.config.buchestache)
        ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, started, finished, unique_id, data|
          # Preserve explicitely set data
          Buchestache.store.merge!(data) { |key, old_val, new_val| old_val }
        end
        app.config.middleware.use Buchestache::Middleware
      end
    end
  end
end
