#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <speex/speex.h>
#include <stdio.h>
#include <stdlib.h>
#include <speex/speex_callbacks.h>

#ifdef FIXED_DEBUG
extern long long spx_mips;
#endif

#define FRAME_SIZE 320
#include <math.h>
int main(int argc, char **argv)
{
   char *inFile, *outFile;
   FILE *fin, *fout =NULL;
   short in_short[FRAME_SIZE];
   char cbits[200];
   int nbBits;
   int i,j;
   int sReadBytes;
   void *st;
   SpeexBits bits;
   spx_int32_t tmp;
   int bitCount=0;
   spx_int32_t skip_group_delay;
   SpeexCallback callback;
   char *dotPtr;
   int dotLength = 0;

   st = speex_encoder_init(speex_lib_get_mode(SPEEX_MODEID_WB));

   callback.callback_id = SPEEX_INBAND_CHAR;
   callback.func = speex_std_char_handler;
   callback.data = stderr;

   callback.callback_id = SPEEX_INBAND_MODE_REQUEST;
   callback.func = speex_std_mode_request_handler;
   callback.data = st;
   tmp=0;
   speex_encoder_ctl(st, SPEEX_SET_VBR, &tmp);
   tmp=8;
   speex_encoder_ctl(st, SPEEX_SET_QUALITY, &tmp);
   tmp=3;
   speex_encoder_ctl(st, SPEEX_SET_COMPLEXITY, &tmp);
   /*tmp=3;
   speex_encoder_ctl(st, SPEEX_SET_HIGH_MODE, &tmp);
   tmp=6;
   speex_encoder_ctl(st, SPEEX_SET_LOW_MODE, &tmp);
*/

   speex_encoder_ctl(st, SPEEX_GET_LOOKAHEAD, &skip_group_delay);
   skip_group_delay += tmp;


   if (argc != 3 && argc != 2)
   {
      fprintf (stderr, "Usage: %s [in file] [out file]\n", argv[0]);
      exit(1);
   }
   inFile = argv[1];
   fin = fopen(inFile, "rb");
   if (fin==NULL) {
      fprintf (stderr, "%s: cannot decode '%s': No such File\n ", argv[0], argv[1]);
      exit(1);
   } 
   if (argc==2) {
   /* No out-file defined*/
     /* last observation of '.' for detecting File-Extension*/
     dotPtr = strrchr(argv[1], '.');
     if (dotPtr != NULL) {
      dotLength = dotPtr - argv[1];
     }
     else {
      /* no '.' in name */
      dotLength = strlen(argv[1]);
     }
     /* reserve Space for name plus ".spx\0" */
     outFile = malloc(dotLength + 5);
     strncpy(outFile, argv[1], dotLength );
     outFile[dotLength] ='\0';
     strcat(outFile, ".spx");
     fout = fopen(outFile, "wb+");
     free(outFile);
   }
   else { /* argc == 3*/
    outFile = argv[2];
    fout = fopen(outFile, "wb+");
   }
   speex_bits_init(&bits);
   while (!feof(fin))
   {
      sReadBytes = fread(in_short, sizeof(short), FRAME_SIZE, fin);
      if (feof(fin))
         break;
      speex_bits_reset(&bits);

      speex_encode_int(st, in_short, &bits);
      nbBits = speex_bits_write(&bits, cbits, 200);

      fwrite(cbits, 1, nbBits, fout);
      bitCount+=bits.nbBits;
      speex_bits_rewind(&bits);
   }
   /* if processing was stop here, there would be missing the last samples of original file. */
   /* This causes a "pop" after the voice prompt. */
   /* fillout current frame with zeros and add another zero-frame afterwards */
   for (j=0; j<1; j++) {
   /* fill out residual samples of frame with zeros */
     for (i=sReadBytes; i<FRAME_SIZE; i++) {
      in_short[i] = 0;
      sReadBytes = 0;
     }
    speex_bits_reset(&bits);
    speex_encode_int(st, in_short, &bits);
    nbBits = speex_bits_write(&bits, cbits, 200);
      bitCount+=bits.nbBits;

      fwrite(cbits, 1, nbBits, fout);

   }
   fprintf (stderr, "Total encoded size: %d bits\n", bitCount);
   speex_encoder_destroy(st);
   speex_bits_destroy(&bits);

   return 1;
}
