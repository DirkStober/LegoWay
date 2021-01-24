#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"
#include <stdint.h>
#include "lqg_lego_controller.h"
#include "bt.h"

// Deadzone of the motor the output voltage of -8 - +8V will be scaled to 
// a value between -100 - +100 for the motors the deadzone value will be
// added default 40
#define NXT_MOTORS_DEADZONE 30  


int F_A_S_T[2] = {2000,6000};

float F_S_GAIN[3]= {1.0,1.0,1.0};

int F_S_OFFSET[3] = {0,0,0};

float F_S_DRIFT[3]= {0,0,0};

float F_A_GAIN[2] = {1.0,1.0}; 

int F_A_OFFSET[2] = {0,0};
