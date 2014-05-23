#ifndef SU_UTILS_RUBYLIB_H_
#define SU_UTILS_RUBYLIB_H_

// Need to define these when linking the VS2013 CRT with MT - otherwise there
// are build errors.
#define HAVE_ACOSH 1
#define HAVE_ROUND 1
#define HAVE_ERF 1
#define HAVE_TGAMMA 1
#define HAVE_CBRT 1

#include <ruby.h>
#include <ruby/encoding.h>

#endif // SU_UTILS_RUBYLIB_H_
