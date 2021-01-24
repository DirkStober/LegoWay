/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_lqg_lego_controller_api.c
 *
 * Code generation for function 'lqg_lego_x_next'
 *
 */

/* Include files */
#include "_coder_lqg_lego_controller_api.h"
#include "_coder_lqg_lego_controller_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131595U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "lqg_lego_controller",               /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real32_T y[8]);
static const mxArray *b_emlrt_marshallOut(const int32_T u[2]);
static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  char_T *identifier, int32_T y[7]);
static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, int32_T y[7]);
static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real32_T ret[8]);
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *x, const
  char_T *identifier, real32_T y[8]);
static const mxArray *emlrt_marshallOut(const real32_T u[8]);
static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, int32_T ret[7]);

/* Function Definitions */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real32_T y[8])
{
  int32_T i;
  real32_T fv[8];
  e_emlrt_marshallIn(sp, emlrtAlias(u), parentId, fv);
  for (i = 0; i < 8; i++) {
    y[i] = fv[i];
  }

  emlrtDestroyArray(&u);
}

static const mxArray *b_emlrt_marshallOut(const int32_T u[2])
{
  static const int32_T iv[1] = { 2 };

  const mxArray *m;
  const mxArray *y;
  int32_T *pData;
  y = NULL;
  m = emlrtCreateNumericArray(1, &iv[0], mxINT32_CLASS, mxREAL);
  pData = (int32_T *)emlrtMxGetData(m);
  *pData = u[0];
  pData[1] = u[1];
  emlrtAssign(&y, m);
  return y;
}

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  char_T *identifier, int32_T y[7])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  d_emlrt_marshallIn(sp, emlrtAlias(u), &thisId, y);
  emlrtDestroyArray(&u);
}

static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, int32_T y[7])
{
  int32_T iv[7];
  int32_T i;
  f_emlrt_marshallIn(sp, emlrtAlias(u), parentId, iv);
  for (i = 0; i < 7; i++) {
    y[i] = iv[i];
  }

  emlrtDestroyArray(&u);
}

static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real32_T ret[8])
{
  static const int32_T dims[2] = { 1, 8 };

  int32_T i;
  real32_T (*r)[8];
  emlrtCheckBuiltInR2012b(sp, msgId, src, "single", false, 2U, dims);
  r = (real32_T (*)[8])emlrtMxGetData(src);
  for (i = 0; i < 8; i++) {
    ret[i] = (*r)[i];
  }

  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *x, const
  char_T *identifier, real32_T y[8])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(sp, emlrtAlias(x), &thisId, y);
  emlrtDestroyArray(&x);
}

static const mxArray *emlrt_marshallOut(const real32_T u[8])
{
  static const int32_T iv[1] = { 8 };

  const mxArray *m;
  const mxArray *y;
  int32_T b_i;
  int32_T i;
  real32_T *pData;
  y = NULL;
  m = emlrtCreateNumericArray(1, &iv[0], mxSINGLE_CLASS, mxREAL);
  pData = (real32_T *)emlrtMxGetData(m);
  i = 0;
  for (b_i = 0; b_i < 8; b_i++) {
    pData[i] = u[b_i];
    i++;
  }

  emlrtAssign(&y, m);
  return y;
}

static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, int32_T ret[7])
{
  static const int32_T dims[2] = { 1, 7 };

  int32_T (*r)[7];
  int32_T i;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "int32", false, 2U, dims);
  r = (int32_T (*)[7])emlrtMxGetData(src);
  for (i = 0; i < 7; i++) {
    ret[i] = (*r)[i];
  }

  emlrtDestroyArray(&src);
}

void lqg_lego_controller_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  lqg_lego_controller_xil_terminate();
  lqg_lego_controller_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void lqg_lego_controller_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

void lqg_lego_controller_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void lqg_lego_x_next_api(const mxArray * const prhs[2], const mxArray *plhs[1])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  int32_T u[7];
  real32_T x[8];
  real32_T x_o[8];
  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "x", x);
  c_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "u", u);

  /* Invoke the target function */
  lqg_lego_x_next(x, u, x_o);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(x_o);
}

void lqg_lego_y_api(const mxArray * const prhs[2], const mxArray *plhs[1])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  int32_T u[7];
  int32_T y[2];
  real32_T x[8];
  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "x", x);
  c_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "u", u);

  /* Invoke the target function */
  lqg_lego_y(x, u, y);

  /* Marshall function outputs */
  plhs[0] = b_emlrt_marshallOut(y);
}

/* End of code generation (_coder_lqg_lego_controller_api.c) */
