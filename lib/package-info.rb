# encoding: utf-8
require 'csv'

class PackageInfo
  COPYRIGHT_FIELDS = ["License-Title", "Format", "Upstream-Name", "Upstream-Contact",
                      "Source", "Disclaimer", "Comment", "License", 
                      "Copyright", "Files"]

  LICENSE_TAGS = ["gpl", "mit", "license", "license"]

  LICENSE_TITLE_TAGS = ["GPL", "LGPL-2+", "LGPL-2.1+", "LGPL-2", "LGPL-3", "LGPL-3+",
                        "MPL-1.1", "BSD-2", "zlib", "MIT", "MPL", "ISC",
                        "BSD", "Boost", "Apache", "BSD-3", "Cisco",
                        "Apache 2.0", "Apache 1.0", "Apache 1.1", "LGPL",
                        "ASL", "Artistic", "OFL", "CC-BY-SA", "CPL"]

  COPYRIGHT_TAGS = ["copyright"]

  UPSTREAM_NAME_TAGS = ["author", "developer", "upstream"]

  FILES_TAGS = ["files"]

  DISCLAIMER_TAGS = ["disclaimer"]

  FORMAT_TAGS = ["format", "html", "txt"]

  APT_SUMMARY_FIELDS = ["Package", "Version", "Description-en", "Homepage"]

  LICENSE_SUMMARY_TAGS = ["License"]

  def create_package_file filename = "packages@#{`hostname`}.csv"
    write_header(filename)
    CSV.open(filename, "ab") do |csv|
      get_package_list.each {|package| csv << get_package_info(package).values}
    end
  end

  def create_package_file_summary filename = "packages@#{`hostname`}.csv"
    write_header_summary(filename)
    CSV.open(filename, "ab") do |csv|
      get_package_list.each {|package| 
        csv << get_package_info_summary(package).values
      }
    end
  end

  def get_package_list
    `dpkg --get-selections | grep -v "deinstall" | cut -f1 | cut -d':' -f1`.split("\n")
  end

  def get_package_info package
    puts "retrieve info for #{package}"
    [parse_package_info(package), parse_copyright_file(package)].inject(:merge)
  end

  def get_package_info_summary package
    puts "retrieve summary for #{package}"
    [parse_package_info_summary(package), parse_copyright_file_summary(package)].inject(:merge)
  end

  def parse_package_info_summary package
    fields, string_fields = init_package_summary_hash, `apt-cache show #{package}`.split("\n")
    string_fields.each do |field|
      if APT_SUMMARY_FIELDS.include?(field.split(": ")[0])
        fields[field.split(": ")[0]] = field.split(": ")[1]
      end
    end
    fields
  end

  def init_package_summary_hash
    hash = {}
    APT_SUMMARY_FIELDS.each {|field| hash[field] = ""}
    hash
  end

  def parse_package_info package
    fields, string_fields = {}, `apt-cache show #{package}`.split("\n")
    string_fields.each {|field| fields[field.split(": ")[0]] = field.split(": ")[1]}
    fields
  end

  def parse_copyright_file package
    return {} if !File.exists?("/usr/share/doc/#{package}/copyright")
    text = File.read("/usr/share/doc/#{package}/copyright")
    is_dep_5_compatible?(text) ? parse_dep_5_compatible(text) : parse_non_dep_5_compatible(text)
  end

  def parse_copyright_file_summary package
    return {} if !File.exists?("/usr/share/doc/#{package}/copyright")
    text = File.read("/usr/share/doc/#{package}/copyright")
    parse_license_summary(text)
  end

  private

  def write_header filename
    CSV.open(filename, "w") do |csv|
      csv << get_package_info(get_package_list.first).keys
    end
  end

  def write_header_summary filename
    CSV.open(filename, "w") do |csv|
      csv << APT_SUMMARY_FIELDS + LICENSE_SUMMARY_TAGS
    end
  end

  def is_dep_5_compatible? text
    text.include?("Copyright:")
  end

  def parse_dep_5_compatible text
    fields, lines = {}, text
      .encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      .split(/\n/)
    field_name, field_content = "", ""

    lines.each do |line|
      field_name, field_content = parse_dep_5_line(line, field_name, field_content)
      if COPYRIGHT_FIELDS.include?(field_name)
        fields[field_name] = field_content
      end
    end
    fields
  end

  def parse_non_dep_5_compatible text
    fields, paragraphs = init_fields_hash, text.split(/^$\n/)

    paragraphs.each do |paragraph|
      case
      when match_tags(LICENSE_TAGS, paragraph)
        fields["License-Title"] += add_license_titles(LICENSE_TITLE_TAGS, paragraph)
        fields["License"] += paragraph
      when match_tags(LICENSE_TAGS, paragraph)
        fields["License"] += paragraph
      when match_tags(COPYRIGHT_TAGS, paragraph)
        fields["Copyright"] += paragraph
      when match_tags(UPSTREAM_NAME_TAGS, paragraph)
        fields["Upstream-Name"] += paragraph
      when match_tags(FILES_TAGS, paragraph)
        fields["Files"] += paragraph
      when match_tags(DISCLAIMER_TAGS, paragraph)
        fields["Disclaimer"] += paragraph
      when match_tags(FORMAT_TAGS, paragraph)
        fields["Format"] += paragraph
      end
    end
    fields
  end

  def parse_license_summary text
    fields, license_tags = {"License" => ""}, []
    LICENSE_TITLE_TAGS.each {|tag| license_tags << tag if text.include?(tag) }
    fields["License"] = license_tags.join(", ")
    fields
  end

  def parse_dep_5_line line, field_name, field_content
    if line.include?(": ")
      field_name, field_content = line.split(": ")[0], line.split(": ")[1]
    else
      line = "" if line.nil?
      field_content = "" if field_content.nil?
      field_content += "\n" + line
    end
    return field_name, field_content
  end

  def init_fields_hash
    fields = {}
    COPYRIGHT_FIELDS.each {|f| fields[f] = ""}
    fields
  end

  def add_license_titles tags, paragraph
    titles = ""
    tags.each {|tag| titles += tag + ", " if paragraph.include?(tag)}
    titles
  end

  def match_tags tags, paragraph
    tags.each {|tag| return true if paragraph.downcase.include?(tag)}
    false
  end
end
