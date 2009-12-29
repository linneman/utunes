README for uconnect_speex_enc
=============================

What is uconnect_speex_enc?
---------------------------
All audio prompt files on the U-Connect hands-free communication system are stored within a compressed audio file format based on the open source speex codec. 

The tunes web application needs the binary command line tool uconnect_speex_enc to convert PCM audio data into this file format. uconnect_speex_enc depends on a single c source file and the speex development package which is shipped with most Linux/BSD distributions.

Howto compile speex:
--------------------

* download, compile and install the speex development package, e.g. for 

    Mac-Ports:      # port install speex-devel
    Debian:         # apt-get install libspeex-dev

    from Source:    
        # download source tarball from http://www.speex.org
        # tar xvfz speex.tar.gz
        # cd speex[xxx]
        # ./configure
        # make
        # make install

* compile uconnect_speex_enc binary application:
     # gcc -I<path_to_add_on_includes> -L<path_to_add_on_libraries> -o uconnect_speex_enc speex_enc.c -lspeex

   example for mac ports:
     # gcc -I/opt/local/include -L/opt/local/lib -o uconnect_speex_enc speex_enc.c -lspeex
	
* install uconnect_speex_enc to system path /usr/local/bin or /usr/bin
     # cp uconnect_speex_enc /usr/bin

2009, Otto Linnemann
