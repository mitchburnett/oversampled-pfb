#ifndef TYPEDEFS_H
#define TYPEDEFS_H

#include <complex>
#include "ap_fixed.h"

typedef float coeff_t;
// TODO: move to fixed point (e.g., ap_fixed)
typedef std::complex<float> cx_datain_t;
typedef std::complex<float> cx_dataout_t;

struct os_pfb_axis_t {
  cx_dataout_t data;
  ap_uint<1> last;
};

#endif // TYPEDEFS_H

