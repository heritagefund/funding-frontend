class User::RegistrationsController < Devise::RegistrationsController

  # Override the Devise::RegistrationsController create method
  # resource refers to the User object being created
  def create
      super do
        # Check that the user model is valid so that we do not create an empty
        # Organisation or an empty Person if validation fails
        if resource.valid?

          person = Person.create(email: resource.email)
          organisation = Organisation.create

          resource.organisation_id = organisation.id
          resource.person_id = person.id

        end
        resource.save
      end
  end
end
