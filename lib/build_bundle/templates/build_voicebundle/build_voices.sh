# build_content.sh  major_current.minor_current.build_current
# 
# script for building new update archive
# of given configuration. You need a bash
# shell environment, tar, gzip, md5sum, sed, xargs
# e.g. a linux OS or cygwin installed on 
# your PC to make it work.
# 
# Make sure to compile project with the macro
# try to load from PC deactivated
#
# 2006 Peiker acustic

# Imports variable n (archive counter) 

rm -R -f content

# integrate everything from the directory prompts
cp -R prompts content
cd content

major_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\1/')
minor_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\2/')
build_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\3/')

tar cvfz ../content.tgz *
cd ..
rm -R -f content
