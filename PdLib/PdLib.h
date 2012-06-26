/*
 *  pd_main.h
 *  Pd-commandline
 *
 *  Created by Bryan Summersett on 11/5/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#ifndef PD_MAIN_H
#define PD_MAIN_H

#ifdef __cplusplus
extern "C" {
#endif
    
#pragma mark pdLib constants

// Flags passed in to initialize PdLib. These can be bitwise OR'd together to 
// combine their effects. 
/*!
 @enum			PdLibArgFlags
 @constant		kPdLibArgQuietModeFlag
                    Flag indicating that the library should not print any messages
                    to stderr. Cancels out any other message-specific flags. 
 @constant      kPdLibArgDebugModeFlag
                    Flag indicating that the library should send out debug messages
*/
enum {
    kPdLibArgQuietModeFlag  = (1<<0),
    kPdLibArgDebugModeFlag  = (1<<1)
};

// These constants are returned from every library call to the system if there
// was an error. 
/*!
 @enum			PdLibErr
 @constant		kPdLibErrNotInitialized
                     Flag indicating that pdLibInitialize was not successfully
                     initialized before calling another library function
 @constant		kPdLibErrAlreadyInitialized
                    Flag indicating that pdLibInitialize has already been called
                    and we can't do it again. 
 @constant      kPdLibErrFileNotFound
                    The given file name wasn't found
 @constant      kPdLibErrFileParse
                    The given file couldn't be read
 @constant      kPdLibErrUnknown
 */
enum {
   kPdLibErrNotInitialized = 1000,
   kPdLibErrAlreadyInitialized,
   kPdLibErrCoreAudio,
   kPdLibErrFileNotFound,
   kPdLibErrFileParse,
   kPdLibErrUnknown,
};

#pragma mark PdLib APIs

const char *PdLibErrToString(OSStatus err);

/*!
 @function       PdLibInitialize
 @abstract       used to initialize the Pure data library
 @discussion     this call starts the Pure data library. Note that Pure Data
                 is NOT thread-safe, so only one global initialization is possible. 
 @param          inPdLibArgFlags
                    The desired initialization settings
 @result		an OSStatus result code.
 */
OSStatus PdLibInitialize(UInt32 inPdLibArgFlags);
    
/*!
 @function      PdLibDestruct
 @abstract      used to destroy a running PureData library
 @result        an OSStatus result code.
                    kPdLibErrNotInitialized if the library hasn't yet been initialized.
 */
OSStatus PdLibDestruct(void);

/*!
 @function       PdLibOpenFile
 @abstract       Open a given PD file. 
 @discussion     Opens the PD file and adds it to the list of open canvases. After
                 this, clients will be able to send / receive any messages from this
                 file. 
 @param          inFileName
                 The file name of the ".pd" file we're looking to open for use. 
 @result		 an OSStatus result code.
                    kPdLibErrNotInitialized if the library hasn't yet been initialized
                    kPdLibErrFileNotFound
                    kPdLibErrFileParse if the file can't be read
 */
OSStatus PdLibOpenFile(const char *inFileName);


/*!
 @function       PdLibOpenExtern
 @abstract       Loads a given extern file into memory for use. 
 @discussion     This will load the extern. This should be called before any 
                 files containing this extern are loaded into memory, otherwise
                 unspecified outcomes will occur. 
 @param          inExternFileName
                 The file name of the ".pd" file we're looking to open for use, including
                 the extension. 
 @result		an OSStatus result code.
                     kPdLibErrNotInitialized if the library hasn't yet been initialized
                     kPdLibErrFileNotFound
                     kPdLibErrFileParse if the file can't be read 
 */
OSStatus PdLibOpenExtern(const char *inExternFileName);

/*!
 @function       PdLibSendMessage
 @abstract       Does a "send~" call to a given receiver. 
 @discussion     Sends a message to a receiver. If none exists, this does nothing. 
 @param          inMessage
                    The message string we're sending. The advantage of this over a
                    (symbol, atom) tuple is that we can treat this just like a PD
                    message -- i.e., we can do multiples messages in one call. 
 @result		an OSStatus result code.
                    kPdLibErrNotInitialized if the library hasn't yet been initialized
 */
OSStatus PdLibSendMessage(const char *inMessage);

#ifdef __cplusplus
}
#endif
        
#endif /* PD_MAIN_H */
