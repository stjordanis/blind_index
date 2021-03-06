ActiveRecord::Base.logger = $logger

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :users do |t|
  t.string :encrypted_email
  t.string :encrypted_email_iv
  t.string :email_bidx
  t.string :email_ci_bidx
  t.binary :email_binary_bidx
  t.string :encrypted_first_name
  t.string :encrypted_first_name_iv
  t.string :encrypted_last_name
  t.string :encrypted_last_name_iv
  t.string :initials_bidx
  t.string :phone_ciphertext
  t.string :phone_bidx
end

class User < ActiveRecord::Base
  attribute :initials, :string

  attr_encrypted :email, key: SecureRandom.random_bytes(32)
  attr_encrypted :first_name, key: SecureRandom.random_bytes(32)
  attr_encrypted :last_name, key: SecureRandom.random_bytes(32)

  encrypts :phone

  # ensure custom method still works
  def read_attribute_for_validation(key)
    super
  end
end
