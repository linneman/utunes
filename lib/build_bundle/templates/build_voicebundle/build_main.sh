# build.sh  major_min.minor_min.build.min  major_current.minor_current.build_current serial_nr
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



# specify the version to compare within the following directory
export BTHFCK2_MINOR_VERSION_DIR="BTHFCK2_v25v15-04-00_071017_teststream"
# sub archive coutner
export n=0

# extracts version numbers
# version=${1//./' '}
# version=$(echo -n $1 | sed 's/\./ /g')
# version_arr=($version)

major_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\1/')
minor_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\2/')
build_ver=$(echo $1 | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)/\3/')

# specify language array
if [ $major_ver -lt 10  -o  $major_ver -ge 20 ]
then	
	# for NAFTA
	export LANGUAGES=" 
		enu
		spm
		frc"
else
	# for BUX
	export LANGUAGES=" 
		eng
		frf
		spe
		iti
		dun
		ged"
fi

	
if [ ! -z "$1" ] && echo "minimal applicable version = $1" && [ ! -z "$2" ] && echo "maximal appicable version corresponding to this content archive= $2"
then
	echo "generating archive file <command.tgz> ..."
	echo 
else
	echo "Invocation: build.sh  major_min.minor_min.build.min  major_current.minor_current.build_current"
	exit -1
fi  



# create binary content archive. 
if true; then
	./build_voices.sh $2	
fi



# create command archive
rm -R -f ./command
mkdir ./command

# and put it into command directory
mv ./content.tgz ./command
cp updbeeps.pp ./command
cd ./command

# create update script in command directory
echo "# update script for reflashing the BTHFCK2 software packages" > command.sh
echo "# install exclusively for valid sw version range" >> command.sh
echo >> command.sh

echo "if test_serialnr_range s$3:s$3; then" >> command.sh
echo "  echo 'Valid serial number for update present!'" >> command.sh

echo "  if test_version_range v$1:v$2; then" >> command.sh
echo "    echo 'Valid software version for update present!'" >> command.sh
echo "    echo 'Start install process ...'" >> command.sh
echo >> command.sh
echo "    if test_file command/updbeeps.pp; then" >> command.sh
echo "      setup_auto_prompt_player command/updbeeps.pp" >> command.sh
echo "    fi" >> command.sh
echo >> command.sh
echo "    gzip -dvN command/content.tgz" >> command.sh
echo "    tar xvf command/content.tar" >> command.sh
echo >> command.sh
echo "    stop_auto_prompt_player" >> command.sh
echo "    echo 'play <Software update successfully applied. The U-Connect system is restarted.>'" >> command.sh
echo "    play_prompt_id 11504" >> command.sh
echo "    usleep 6000000"  >> command.sh
echo >> command.sh
echo "    cp obex/command.log /reflash.log" >> command.sh
echo "    reset" >> command.sh
echo "  else" >> command.sh
echo "    stop_auto_prompt_player" >> command.sh
echo "    echo 'play <The used update archive is not compatible with this unit>'" >> command.sh
echo "    play_prompt_id 11506" >> command.sh
echo "    usleep 6000000"  >> command.sh
echo "  fi" >> command.sh
echo "else" >> command.sh
echo "  stop_auto_prompt_player" >> command.sh
echo "  echo 'play <The used update archive is not licensed for this unit>'" >> command.sh
echo "  play_prompt_id 11507" >> command.sh
echo "  usleep 6000000"  >> command.sh
echo "fi" >> command.sh

# build packed archive out of the main content directory
cd ..
tar cvf command.tar command
rm -R -f ./command

