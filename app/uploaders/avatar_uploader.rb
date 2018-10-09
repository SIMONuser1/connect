class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
  # process raise
  # Remove everything else
end
