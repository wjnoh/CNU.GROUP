class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:studentid])
  end

  # flash 메시지
  module DeviseHelper
    def devise_error_messages!
      return "" if resource.errors.empty?

      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      sentence = I18n.t("errors.messages.not_saved",
                        count: resource.errors.count,
                        resource: resource.class.model_name.human.downcase)

      html = <<-HTML
      <div id="error_explanation">
        <h6>#{sentence}</h6>
        <ul><span style="color: red;">#{messages}</span></ul>
      </div>
      HTML

      html.html_safe
    end
  end

end
