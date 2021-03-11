# Controller concern used to log model errors
module ObjectErrorsLogger
  extend ActiveSupport::Concern

  # This method writes a debug log line for each error found in a model object's errors hash
  def log_errors(model_object)

    model_object.errors.each do |error|
      logger.debug "Error '#{error.message}', for key '#{error.attribute}'"
    end

  end

end
