module Apartment
  module Elevators
    # Provides a rack based db switching solution based on domains
    # Assumes that tenant model is configured and has class method
    # named "find_database_name_by_domain"
    class Domain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        domain = domain(request)
        database = Apartment.tenant.blank? ? nil : Apartment.tenant.find_database_name_by_domain(domain)
        Apartment::Database.switch database if database

        @app.call(env)
      end

      def domain(request)
        request.server_name.present? && request.server_name || nil
      end
    end
  end
end