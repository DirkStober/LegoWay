/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * lqg_lego_controller.h
 *
 * Code generation for function 'lqg_lego_controller'
 *
 */

#ifndef LQG_LEGO_CONTROLLER_H
#define LQG_LEGO_CONTROLLER_H

/* Include files */
#include <stddef.h>
#include <stdlib.h>
#ifdef __cplusplus

extern "C" {

#endif

  /* Function Declarations */
  extern void lqg_lego_controller_initialize(void);
  extern void lqg_lego_controller_terminate(void);
  extern void lqg_lego_x_next(const float x[8], const int u[7], float x_o[8]);
  extern void lqg_lego_y(const float x[8], const int u[7], int y[2]);

#ifdef __cplusplus

}
#endif
#endif

/* End of code generation (lqg_lego_controller.h) */
