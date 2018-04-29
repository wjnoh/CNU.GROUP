class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # 기본 프로필 설정을 위해 override했음.
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end

        # 프로필 설정 부분
        user = User.find(resource.id)
        if user.gender == "남"
          profile = Array.new(10)
          profile[0] = "/assets/profile/boy-1.png";
          profile[1] = "/assets/profile/boy-2.png";
          profile[2] = "/assets/profile/boy-3.png";
          profile[3] = "/assets/profile/boy-4.png";
          profile[4] = "/assets/profile/boy-5.png";
          profile[5] = "/assets/profile/boy-7.png";
          profile[6] = "/assets/profile/boy-17.png";
          profile[7] = "/assets/profile/boy-12.png";
          profile[8] = "/assets/profile/boy-20.png";
          profile[9] = "/assets/profile/boy-9.png";

          profileRandomNumber = (Array 1..10).sample
          user.update_attributes(profile_picture: profile[profileRandomNumber])
        else
          profile = Array.new(10)
          profile[0] = "/assets/profile/girl-4.png";
          profile[1] = "/assets/profile/girl-8.png";
          profile[2] = "/assets/profile/girl-16.png";
          profile[3] = "/assets/profile/girl-9.png";
          profile[4] = "/assets/profile/girl-6.png";
          profile[5] = "/assets/profile/girl-3.png";
          profile[6] = "/assets/profile/girl-24.png";
          profile[7] = "/assets/profile/girl-26.png";
          profile[8] = "/assets/profile/girl-13.png";
          profile[9] = "/assets/profile/girl-14.png";

          profileRandomNumber = (Array 1..10).sample
          user.update_attributes(profile_picture: profile[profileRandomNumber])
        end


      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end

  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute, :gender])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
