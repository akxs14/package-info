Gem::Specification.new do |s|
  s.name  = 'package-info'
  s.version = '0.0.3'
  s.date = '2014-09-05'
  s.summary = "Displays package information in Debian-based distros."
  s.description = <<-eos
      Retrieves information for all installed packages
      in Debian based distributions and outputs them in
      the console or a CSV file.
  eos
  s.authors = ["Angelos Kapsimanis"]
  s.email = 'angelos.kapsimanis@gmail.com'
  s.files = ["lib/package-info.rb"]
  s.homepage = "https://github.com/akxs14/package-info"
  s.license = "GPL/V3"
end
