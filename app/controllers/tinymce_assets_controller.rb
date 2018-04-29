class TinymceAssetsController < ApplicationController
  # 이 컨트롤러는 이미지 업로더를 수행하기 위해 필요함.
  def create
    image = Image.create params.permit(:file, :alt, :hint)

    render json: {
      image: {
        url: image.file.url
      }
    }, content_type: "text/html"
  end
end
