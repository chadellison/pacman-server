class IpAddress < ApplicationRecord
  def self.handle_ip_address(address)
    ip_address = IpAddress.find_by(address: address)
    if ip_address.present?
      ip_address.update(count: ip_address.count + 1)
    else
      IpAddress.create(address: address, count: 1)
    end
  end
end
