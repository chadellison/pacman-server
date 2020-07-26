class CreateIpAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_addresses do |t|
      t.string :address
      t.integer :count
      t.timestamps
    end
    add_index :ip_addresses, :address
  end
end
