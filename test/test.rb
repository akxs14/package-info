# encoding: utf-8
require 'package-info'

pi = PackageInfo.new

package = pi.parse_copyright_file("python")
package.each {|k,v| puts "#{k} ----- #{v}"}
