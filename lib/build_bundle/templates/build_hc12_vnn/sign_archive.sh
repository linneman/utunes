# Sign content archive command.tar. This is required for USB software update (MY10)
#
# 2008 Peiker acustic

openssl rmd160 command.tar | xargs -n1 | tail -n1 > command.rmd
openssl rsautl -sign -in command.rmd -inkey ../keys/uconnect.pem -out command.sig
rm command.rmd

# create command archive
rm -R -f ./command
mkdir ./command

# and put it into command directory
mv ./command.tar ./command
mv ./command.sig ./command
cd ./command

# create signed tar ball
cd ..
tar cvf command.tar command
rm -R -f ./command
