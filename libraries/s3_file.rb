require 'net/http'
require 'net/https'
require 'time'
require 'openssl'
require 'base64'

module S3File
  def get_from_s3(bucket,path,file_path,aws_access_key_id,aws_secret_access_key)
    now = Time.now().utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
    string_to_sign = "GET\n\n\n%s\n/%s%s" % [now,bucket,path]

    digest = digest = OpenSSL::Digest::Digest.new('sha1')
    signed = OpenSSL::HMAC.digest(digest, aws_secret_access_key, string_to_sign)
    signed_base64 = Base64.encode64(signed)

    auth_string = 'AWS %s:%s' % [aws_access_key_id,signed_base64]

    url = "https://#{bucket}.s3.amazonaws.com"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new("#{url}#{path}")
    request.add_field "Date", now
    request.add_field "Authorization", auth_string
    http.start do |http|
      http.request(request) do |response|
        begin
          file = open("#{file_path}", 'wb')
          response.read_body do |segment|
            file.write(segment)
          end
        ensure
          file.close
        end
      end
    end
  end
end
