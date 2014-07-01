require 'peastash/middleware'
require 'active_support/notifications'

class Peastash
  class Railtie < ::Rails::Railtie
    config.peastash = ActiveSupport::OrderedOptions.new

    initializer 'peastash.configure' do |app|
      if app.config.peastash[:enabled]
        Peastash.with_instance.configure!(app.config.peastash)
        ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, started, finished, unique_id, data|
          # Handle parameters and sanitize if need be
          if Peastash.with_instance.configuration[:log_parameters]
            data[:params].reject! { |k, _| ActionController::LogSubscriber::INTERNAL_PARAMS.include?(k) }
          else
            data.delete(:params)
          end
          # Preserve explicitely set data
          Peastash.with_instance.store.merge!(data) { |key, old_val, new_val| old_val }
        end
        app.config.middleware.use Peastash::Middleware
      end
    end
  end
end
