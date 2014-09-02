# encoding: utf-8
require 'csv'

class PackageInfo
  COPYRIGHT_FIELDS = ["Format", "Upstream-Name", "Upstream-Contact",
                      "Source", "Disclaimer", "Comment", "License", 
                      "Copyright", "Files"]

  LICENSE_TAGS = ["gpl", "mit", "license", "license"]

  COPYRIGHT_TAGS = ["copyright"]

  UPSTREAM_NAME_TAGS = ["author", "developer", "upstream"]

  FILES_TAGS = ["files"]

  DISCLAIMER_TAGS = ["disclaimer"]

  FORMAT_TAGS = ["format"]

  def create_package_file filename = "packages.csv"
    get_package_list.each do |package|
      write_package_info(package)
    end
  end

  def get_package_list
    `dpkg --get-selections | grep -v "deinstall" | cut -f1 | cut -d':' -f1`.split("\n")
  end

  def write_package_info package
    # [parse_package_info(package), parse_copyright_file(package)].inject(:merge)
    parse_copyright_file(package)
  end

  def parse_package_info package
    fields, string_fields = {}, `apt-cache show #{package}`.split("\n")
    string_fields.each {|field| fields[field.split(": ")[0]] = field.split(": ")[1]}
    fields
  end

  def parse_copyright_file package
    text = File.read("/usr/share/doc/#{package}/copyright")
    
    if is_dep_5_compatible?(text) 
      parse_dep_5_compatible(text)
    else
      parse_non_dep_5_compatible(text)
    end
  end

  def is_dep_5_compatible? text
    text.include?("Copyright:")
  end

  def parse_dep_5_compatible text
    fields, lines = {}, text.split(/\n/)
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

  def parse_dep_5_line line, field_name, field_content
    if line.include?(": ")
      field_name, field_content = line.split(": ")[0], line.split(": ")[1]
    else
      field_content += "\n" + line
    end
    return field_name, field_content
  end

  def init_fields_hash
    fields = {}
    COPYRIGHT_FIELDS.each {|f| fields[f] = ""}
    fields
  end

  def match_tags tags, paragraph
    tags.each {|tag| return true if paragraph.downcase.include?(tag)}
    false
  end

end
