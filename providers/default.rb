include S3File

action :create do
  get_from_s3(@new_resource.bucket, @new_resource.remote_path, @new_resource.path, @new_resource.aws_access_key_id, @new_resource.aws_secret_access_key)
end

