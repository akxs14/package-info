# encoding: utf-8

class PackageInfo
  def self.get_package_list
    `dpkg --get-selections | grep -v "deinstall" | cut -f1 | cut -d':' -f1`.split("\n")
  end 
end
