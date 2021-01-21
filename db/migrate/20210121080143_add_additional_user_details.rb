class AddAdditionalUserDetails < ActiveRecord::Migration[6.0]
  def change
    add_column(:users, :communication_needs, :text)
    add_column(:users, :language_preference, :string)
    add_column(:users, :agrees_to_contact, :boolean)
    add_column(:users, :agrees_to_user_research, :boolean)
  end
end
