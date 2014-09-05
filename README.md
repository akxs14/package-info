package-info
============

Collects and outputs in a file all the available information for the installed packages in a debian-based installation.

Usage
-----

To get a CSV file with the information and the licensing for all
packages installed in the current box you need to initialize 
PackageInfo and call create_package_file like

      PackageInfo.new.create_package_file

for the default CSV filename (packages@*your host name*) or for 
a filename of your choice:

      PackageInfo.new.create_package_file(filename)


Public methods:
---------------

      #create_package_file filename = "packages@#{`hostname`}.csv"

Creates a csv file containing the details for all installed packages.

      #create_package_file filename = "packages@#{`hostname`}.csv"

Creates a csv file containing the details for all installed packages, 
similarly to #create_package_file filename but in a shorter form. The 
included fields are the package name, version, description in English,
the package's websiste URL (if any) and the governing license/s.

      #create_package_file filename_summary = "packages@#{`hostname`}.csv"

Returns an array with all installed packages.

      #get_package_info package

Return a hash with the package information for the given package.

      #parse_package_info package

Return a hash with the license and copyright information for the given package. It handles DEP-5 compatible packages and has a limited support
for unstructured, non-DEP-5 compatible packages.
