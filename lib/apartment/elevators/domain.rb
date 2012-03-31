module Apartment
  module Elevators
    # Provides a rack based db switching solution based on domains
    # Assumes that tenant model is configured, has class method
    # named "find_by_domain" and object of this class responds to
    # "database_name"
    class Domain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        domain = domain(request)
        Apartment.current_tenant = Apartment.tenant_model.nil? ? nil : Apartment.tenant_model.find_by_domain(domain)

        raise NoTenantError, "Tenant for domain #{domain} cannot be found." if Apartment.current_tenant.nil?

        Apartment::Database.switch Apartment.current_tenant.database_name

        @app.call(env)
      end

      def domain(request)
        request.server_name.present? && request.server_name || nil
      end
    end
  end
end