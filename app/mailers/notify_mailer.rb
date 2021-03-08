class NotifyMailer < Mail::Notify::Mailer

  before_action { @reply_to_id = "3bd255ca-7071-4cdb-aee8-f554bed5042d" }

  include Devise::Controllers::UrlHelpers


  def confirmation_instructions(record, token, opts = {})
    template_mail('a44293b7-7263-42b4-8905-44bbedaf1dfa',
                  to: record.email,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      confirmation_url: confirmation_url(record, confirmation_token: token)
                  }
    )
  end

  # Use ERB template as Notify does not support required templating logic.
  def email_changed(record, opts = {})
    @resource = record
    view_mail('cd9fbf07-4960-4cb7-903c-068b76d2ca32',
              reply_to_id: @reply_to_id,
              to: @resource.email,
              subject: 'Email changed'
    )
  end


  def password_change(record, opts = {})
    template_mail('32bc1da4-99aa-4fde-9124-6c423cfcab15',
                  reply_to_id: @reply_to_id,
                  to: record.email
    )
  end


  def reset_password_instructions(record, token, opts = {})
    template_mail('343c89d0-0825-4363-a2eb-6a6bbc20a50f',
                  reply_to_id: @reply_to_id,
                  to: record.email,
                  personalisation: {
                      edit_password_url: edit_password_url(record, reset_password_token: token)
                  }
    )
  end

  def unlock_instructions(record, token, opts = {})
    template_mail('8c03a7c0-e23f-484e-9543-bbde9263bd47',
                  reply_to_id: @reply_to_id,
                  to: record.email,
                  personalisation: {
                      unlock_url: unlock_url(record, unlock_token: token)
                  }
    )
  end

  #  @param [Project] project
  def project_submission_confirmation(project)
    template_mail('071cfcda-ebd4-4eba-8602-338b12edc4f9',
                  to: project.user.email,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      project_reference_number: project.funding_application.project_reference_number
                  }
    )
  end

  #  @param [PreApplication] pre_application
  def project_enquiry_submission_confirmation(pre_application)
    template_mail('34ec207b-e8d1-46be-87ee-2eca4b665cbc',
                  to: pre_application.user.email,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      pa_project_enquiry_reference: pre_application.salesforce_case_id
                  }
    )
  end

  #  @param [PreApplication] pre_application
  def expression_of_interest_submission_confirmation(pre_application)
    template_mail('76cba30c-e91b-4fae-bffc-78ee13179b9c',
                  to: pre_application.user.email,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      pa_expression_of_interest_reference: pre_application.pa_expression_of_interest.salesforce_eoi_reference
                  }
    )
  end

  # @param [Project] project
  def payment_request_submission_confirmation(project)
    template_mai(
      'e35a0532-8b51-4447-bc6d-d39f705bd24c',
      to: project.user.email,
      reply_to_id: @reply_to_id,
      personalisation: {
        project_reference_number: project.funding_application.project_reference_number
      }
    )
  end

  def report_a_problem(message, name, email)
    template_mail("4d789cc6-bd6a-499f-bae2-502b633c098b",
                  to: Rails.configuration.x.support_email_address,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      message_body: message,
                      name: name,
                      email_address: email
                  })
  end

  def question_or_feedback(message, name, email)
    template_mail("af4e775b-5a0e-4da2-81a1-3c51dd88a07c",
                  to: Rails.configuration.x.support_email_address,
                  reply_to_id: @reply_to_id,
                  personalisation: {
                      message_body: message,
                      name: name.present? ? name : "Name not provided",
                      email_address: email.present? ? email : "Email address not provided"
                  })
  end

end
