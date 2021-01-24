/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_lqg_lego_controller_api.h
 *
 * Code generation for function 'lqg_lego_x_next'
 *
 */

#ifndef _CODER_LQG_LEGO_CONTROLLER_API_H
#define _CODER_LQG_LEGO_CONTROLLER_API_H

/* Include files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus

extern "C" {

#endif

  /* Function Declarations */
  void lqg_lego_controller_atexit(void);
  void lqg_lego_controller_initialize(void);
  void lqg_lego_controller_terminate(void);
  void lqg_lego_controller_xil_shutdown(void);
  void lqg_lego_controller_xil_terminate(void);
  void lqg_lego_x_next(real32_T x[8], int32_T u[7], real32_T x_o[8]);
  void lqg_lego_x_next_api(const mxArray * const prhs[2], const mxArray *plhs[1]);
  void lqg_lego_y(real32_T x[8], int32_T u[7], int32_T y[2]);
  void lqg_lego_y_api(const mxArray * const prhs[2], const mxArray *plhs[1]);

#ifdef __cplusplus

}
#endif
#endif

/* End of code generation (_coder_lqg_lego_controller_api.h) */
