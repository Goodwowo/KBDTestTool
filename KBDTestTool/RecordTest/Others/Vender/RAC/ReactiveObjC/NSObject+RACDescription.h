
#import <Foundation/Foundation.h>

// A simplified description of the object, which does not invoke -description
// (and thus should be much faster in many cases).
//
// This is for debugging purposes only, and will return a constant string
// unless the RAC_DEBUG_SIGNAL_NAMES environment variable is set.
NSString *RACDescription(id object);

