module Airbrake
  module Rails
    module JavascriptNotifier
      def self.included(base) #:nodoc:
        base.send :helper_method, :airbrake_javascript_notifier
      end

      private

      def airbrake_javascript_notifier_options
        path = File.join File.dirname(__FILE__), '..', '..', 'templates', 'javascript_notifier.erb'
        host = Airbrake.configuration.host.dup
        port = Airbrake.configuration.port
        host << ":#{port}" unless [80, 443].include?(port)

        # Send null instead of empty hash if user not present.
        user = airbrake_current_user
        user = nil if user.blank?

        options              = {
          :file              => path,
          :layout            => false,
          :use_full_path     => false,
          :locals            => {
            :host            => host,
            :api_key         => Airbrake.configuration.js_api_key,
            :environment     => Airbrake.configuration.environment_name,
            :action_name     => action_name,
            :controller_name => controller_name,
            :url             => request.url,
            :user            => user
          }
        }
      end

      def airbrake_javascript_notifier
        return unless Airbrake.configuration.public?

        options = airbrake_javascript_notifier_options

        res = if @template
          @template.render(options)
        else
          render_to_string(options)
        end

        if res.respond_to?(:html_safe)
          res.html_safe
        else
          res
        end

      end
    end
  end
end
