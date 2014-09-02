# encoding: utf-8
require 'package-info'

pi = PackageInfo.new

package = pi.parse_copyright_file("cassandra")
package.each {|k,v| puts "#{k} ----- #{v}"}
