/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * lqg_lego_controller.c
 *
 * Code generation for function 'lqg_lego_controller'
 *
 */

/* Include files */
#include "lqg_lego_controller.h"
#include <math.h>

/* Function Definitions */
void lqg_lego_controller_initialize(void)
{
}

void lqg_lego_controller_terminate(void)
{
  /* (no terminate code required) */
}

void lqg_lego_x_next(const float x[8], const int u[7], float x_o[8])
{
  static const float fv[64] = { 0.981286943F, -1.01914558E-17F, 0.000761398464F,
    0.00198123301F, -1.12899418E-20F, 0.000188565624F, 0.0F, 0.0F,
    7.46641117E-12F, 0.45858565F, -2.98648937E-13F, 7.88580135E-15F,
    0.00137618696F, 6.12735958E-16F, 0.0F, 0.0F, -0.0221607517F,
    -3.69866102E-17F, 1.00088632F, -2.22850522E-5F, -4.08313476E-20F,
    -2.21990899E-6F, 0.0F, 0.0F, -0.0773325637F, -1.11136726E-15F, 0.0158946551F,
    0.999397874F, -3.34326551E-18F, 0.0951389298F, 0.0F, 0.0F, 9.52595669E-10F,
    -71.6733475F, -3.81075345E-11F, 1.07927664E-12F, 0.860742688F,
    8.29226892E-14F, 0.0F, 0.0F, -0.000153201283F, 1.19951046E-14F,
    0.00171983952F, 0.00550929271F, 3.54728134E-17F, 0.000524463889F, 0.0F, 0.0F,
    1.89335039E-14F, 7.01750255E-11F, -7.57355504E-16F, 1.86845476E-17F,
    7.73887654E-14F, 1.25605484E-18F, 0.999999821F, 0.0F, -0.0187128019F,
    3.1277376E-14F, 0.000761388568F, 0.00198123301F, 3.44925283E-17F,
    0.000188565624F, 0.0F, 0.999999821F };

  static const float fv1[56] = { 9.72471104E-10F, 9.72471104E-10F,
    0.00037426097F, 0.00037426097F, 0.000187806334F, 0.0F, 0.0F, 2.43153445E-5F,
    -2.43153445E-5F, 0.13535358F, -0.13535358F, 9.28177539E-16F, 0.0F, 0.0F,
    2.34860686E-9F, 2.34860686E-9F, 0.000443215045F, 0.000443215045F,
    -0.00200311118F, 0.0F, 0.0F, 2.12927316E-5F, 2.12927316E-5F, 0.00154665124F,
    0.00154665124F, 0.0951022F, 0.0F, 0.0F, 0.0291543733F, -0.0291543733F,
    17.9183369F, -17.9183369F, 1.2610037E-13F, 0.0F, 0.0F, -0.000223606694F,
    -0.000223606694F, 3.06402558E-6F, 3.06402558E-6F, -0.999258518F, 0.0F, 0.0F,
    8.50266919E-16F, -8.50242143E-16F, 0.000499999907F, -0.000499999907F,
    2.00349162E-18F, -0.00199999986F, 0.0F, 9.72467329E-10F, 9.72467329E-10F,
    0.000374256022F, 0.000374256022F, 0.000187806349F, 0.0F, -0.00199999986F };

  float u_in[7];
  float f;
  float f1;
  int i;
  int i1;

  /*  function x_o = lgq_lego_x_next(x,u) */
  /*      %#codegen */
  /*      A = (coder.const(feval('evalin','base','lgq_controller_gen_A'))); */
  /*      B = (coder.const(feval('evalin','base','lgq_controller_gen_B'))); */
  /*      x_o = A*x' + B*single(u)'; */
  /*  end */
  for (i = 0; i < 7; i++) {
    u_in[i] = (float)u[i];
  }

  u_in[0] *= 0.13333334F;
  u_in[1] *= 0.13333334F;
  for (i = 0; i < 8; i++) {
    f = 0.0F;
    for (i1 = 0; i1 < 8; i1++) {
      f += x[i1] * fv[i1 + (i << 3)];
    }

    f1 = 0.0F;
    for (i1 = 0; i1 < 7; i1++) {
      f1 += u_in[i1] * fv1[i1 + 7 * i];
    }

    x_o[i] = f + f1;
  }
}

void lqg_lego_y(const float x[8], const int u[7], int y[2])
{
  static const float fv[16] = { 0.0F, -8.20520496F, 33.5972404F, 28.6595688F,
    -0.239724353F, 3.50675535F, -7.07024717F, 7.06943369F, 0.0F, 8.20520496F,
    33.5972404F, 28.6595688F, 0.239724353F, 3.50675535F, 7.07024717F,
    7.06943369F };

  static const float fv1[14] = { 0.0F, 0.0F, 0.0F, 0.0F, 0.0F, 8.20520687F,
    -16.3407593F, 0.0F, 0.0F, 0.0F, 0.0F, 0.0F, -8.20520687F, -16.3407593F };

  float tmp[2];
  float f;
  float f1;
  int i;
  int i1;

  /*  changed 100 -> 60 */
  for (i = 0; i < 2; i++) {
    f = 0.0F;
    for (i1 = 0; i1 < 8; i1++) {
      f += x[i1] * fv[i1 + (i << 3)];
    }

    f1 = 0.0F;
    for (i1 = 0; i1 < 7; i1++) {
      f1 += (float)u[i1] * fv1[i1 + 7 * i];
    }

    tmp[i] = (f + f1) * 60.0F / 8.0F;
  }

  y[0] = (int)roundf(fminf(60.0F, fmaxf(-60.0F, tmp[0])));
  y[1] = (int)roundf(fminf(60.0F, fmaxf(-60.0F, tmp[1])));
}

/* End of code generation (lqg_lego_controller.c) */
