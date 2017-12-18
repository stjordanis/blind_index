# dependencies
require "active_support"

# modules
require "blind_index/extensions"
require "blind_index/model"
require "blind_index/version"

module BlindIndex
  class Error < StandardError; end

  def self.generate_bidx(value, key:, iterations:, expression: nil, **options)
    raise BlindIndex::Error, "Missing key for blind index" unless key

    # apply expression
    value = expression.call(value) if expression

    # generate hash
    digest = OpenSSL::Digest::SHA256.new
    value = OpenSSL::PKCS5.pbkdf2_hmac(value.to_s, key, iterations, digest.digest_length, digest)

    # encode
    [value].pack("m")
  end
end

ActiveSupport.on_load(:active_record) do
  extend BlindIndex::Model
  ActiveRecord::TableMetadata.prepend(BlindIndex::Extensions::TableMetadata)
  if ActiveRecord::VERSION::STRING.start_with?("5.0.")
    ActiveRecord::Validations::UniquenessValidator.prepend(BlindIndex::Extensions::UniquenessValidator)
  end
end
