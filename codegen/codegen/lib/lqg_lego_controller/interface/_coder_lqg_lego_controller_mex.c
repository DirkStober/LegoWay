/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_lqg_lego_controller_mex.c
 *
 * Code generation for function 'lqg_lego_x_next'
 *
 */

/* Include files */
#include "_coder_lqg_lego_controller_mex.h"
#include "_coder_lqg_lego_controller_api.h"

/* Variable Definitions */
static const char_T *emlrtEntryPoints[2] = { "lqg_lego_x_next", "lqg_lego_y" };

/* Function Definitions */
void lqg_lego_x_next_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs,
  const mxArray *prhs[2])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  const mxArray *outputs[1];
  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4,
                        15, "lqg_lego_x_next");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 15,
                        "lqg_lego_x_next");
  }

  /* Call the function. */
  lqg_lego_x_next_api(prhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void lqg_lego_y_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs, const
  mxArray *prhs[2])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  const mxArray *outputs[1];
  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4,
                        10, "lqg_lego_y");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 10,
                        "lqg_lego_y");
  }

  /* Call the function. */
  lqg_lego_y_api(prhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexAtExit(&lqg_lego_controller_atexit);

  /* Module initialization. */
  lqg_lego_controller_initialize();
  st.tls = emlrtRootTLSGlobal;

  /* Dispatch the entry-point. */
  switch (emlrtGetEntryPointIndexR2016a(&st, nrhs, prhs, emlrtEntryPoints, 2)) {
   case 0:
    lqg_lego_x_next_mexFunction(nlhs, plhs, nrhs - 1, *(const mxArray *(*)[2])&
      prhs[1]);
    break;

   case 1:
    lqg_lego_y_mexFunction(nlhs, plhs, nrhs - 1, *(const mxArray *(*)[2])&prhs[1]);
    break;
  }

  /* Module termination. */
  lqg_lego_controller_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_lqg_lego_controller_mex.c) */
