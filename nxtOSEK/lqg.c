/* helloworld.c for TOPPERS/ATK(OSEK) */ 
#include "lqg.h"

/* OSEK declarations*/
/* Tasks */
DeclareTask(TaskM);
DeclareTask(TaskReadSensors);
DeclareTask(TaskWriteMotors);
DeclareTask(TaskBT);

/* EVENTS: */
DeclareEvent(EVENT_SENSORS_START);
DeclareEvent(EVENT_SENSORS_FINISHED);
DeclareEvent(EVENT_MOTORS_START);
DeclareEvent(EVENT_MOTORS_FINISHED);
DeclareEvent(EVENT_BT_START);
DeclareEvent(EVENT_BT_FINISHED);

/* nxtOSEK hook to be invoked from an ISR in category 2 */
void user_1ms_isr_type2(void){}

/* Declare global variables */
int offset_gyro;
int y_vector[7] = {0};
int * sensor_values;
int * ref_values;
int * control_values;
float x_vector[16] = {0};
float * x_current;
float * x_next;
uint8_t fault_active = 0;

/* holds data send to matlab*/
int data_package[102] = {0};
int * swp_data;
int iteration = 0;
int * data_array;



int init_gyro(int gyro_port);
void disp_info(int * timer_values);
void disp_message(char * mesg);
int deadzone_off(int d_in);
void display_fault_values();



TASK(TaskM)
{
	
	/* Assign x_current and x_next */
	x_current = x_vector;
	x_next = &x_vector[8];
	/* Assign sensor values pointer */
	sensor_values = &y_vector[2];
	ref_values = &y_vector[5];
	control_values = y_vector;
	ref_values[0] = 0;
	ref_values[1] = 0;
	/* Two arrays for data to be sent to host swap them around
	 * if one of them is to be sent
	 */
	iteration = 0;
	data_array = data_package;
	swp_data = &data_package[51];

	/* Start the initialization of controller */
	offset_gyro = init_gyro(NXT_PORT_S2);	
	disp_message("Press Enter");
	int wait = 1;
	while(wait){
		if(ecrobot_is_ENTER_button_pressed()){
			wait = 0;
		}
		systick_wait_ms(100);
	};
	display_fault_values();
	systick_wait_ms(500);
	
	/* Set the motor count to 0 */
	nxt_motor_set_count(NXT_PORT_A,0);
	nxt_motor_set_count(NXT_PORT_B,0);

	int runtime = 0;
	unsigned int iter_start;
	int iter_stop;
	// max iteration time
	int max_iter_time = 2;
	/* Start the controller */

	while(1){
		iter_start = systick_get_ms();
		SetEvent(TaskReadSensors,EVENT_SENSORS_START);		
		/* Wait for the sensor values to be read */
		WaitEvent(EVENT_SENSORS_FINISHED);
		ClearEvent(EVENT_SENSORS_FINISHED);
		/* Start the calculation of the motor signals and send them*/
		SetEvent(TaskWriteMotors,EVENT_MOTORS_START);
		lqg_lego_x_next(x_current,y_vector,x_next);

		/* Wait for the Motor signals to be finished */
		WaitEvent(EVENT_MOTORS_FINISHED);
		ClearEvent(EVENT_MOTORS_FINISHED);
		float * tmp = x_next;
		x_current = x_next;
		x_next = tmp;
		//disp_info(&runtime);

		/* Start bt data */
		if(iteration >= 9){
			WaitEvent(EVENT_BT_FINISHED);
			ClearEvent(EVENT_BT_FINISHED);
			iteration = 0;
			int * tmp = data_array;
			data_array = swp_data;
			swp_data = tmp;
			data_array[0] = runtime;
			SetEvent(TaskBT,EVENT_BT_START);
		}
		else{
			iteration++;
		}
		
		// Inject Fault after F_A_S_T
		if((runtime > F_A_S_T[0]) && (F_A_S_T[0] > 0)){
			if((runtime < F_A_S_T[1]) || (F_A_S_T[1] < 1)){
				fault_active = 1;
			}
			else{
				fault_active = 0;
			};
		};


		runtime++;
		iter_stop = systick_get_ms() - iter_start;
		
		// TODO: Write an error routine if deadlines
		// are not met
		
		if(iter_stop > max_iter_time){
			disp_message("ERROR: TASK");
			systick_wait_ms(10000);
		}
		else{
			while(iter_stop < max_iter_time){
				iter_stop = systick_get_ms() - iter_start;
			}
		};
			
	}
}


TASK(TaskReadSensors)
{
	int drift = 0;
	while(1){
		WaitEvent(EVENT_SENSORS_START);
		ClearEvent(EVENT_SENSORS_START);
		sensor_values[0] = ecrobot_get_motor_rev(NXT_PORT_A);
		sensor_values[1] = ecrobot_get_motor_rev(NXT_PORT_B);
		sensor_values[2]= -(ecrobot_get_gyro_sensor(NXT_PORT_S2)
				-offset_gyro);
		if(fault_active ==1){
			// Apply Faults
			int i;
			for(i = 0; i < 3;i++){
				sensor_values[i] = 
					F_S_GAIN[i]*sensor_values[i]+ 
					F_S_OFFSET[i]+drift*F_S_DRIFT[i];
			}
			drift++;
		}
		int i;
		for(i = 0;i<3; i++){
			data_array[iteration*5+i+1 ] = sensor_values[i]; 
		};
		SetEvent(TaskM,EVENT_SENSORS_FINISHED);
	};
	TerminateTask();
}

TASK(TaskWriteMotors)
{
	while(1){
		WaitEvent(EVENT_MOTORS_START);
		ClearEvent(EVENT_MOTORS_START);
		lqg_lego_y(x_current,y_vector,control_values);		
		int u[2];

		if(fault_active == 0){
			u[0] = control_values[0];
			u[1] = control_values[1];
		}
		else{	
			u[0] =F_A_GAIN[0]*control_values[0]+F_A_OFFSET[0];
			u[1] =F_A_GAIN[1]*control_values[1]+F_A_OFFSET[1];
		}
		nxt_motor_set_speed(NXT_PORT_A,deadzone_off(u[0]),0);
		nxt_motor_set_speed(NXT_PORT_B,deadzone_off(u[1]),0);
		data_array[iteration*5 + 3 + 1] =control_values[0];
		data_array[iteration*5 + 4 + 1] = control_values[1];
		
		SetEvent(TaskM,EVENT_MOTORS_FINISHED);
	}
	TerminateTask();
};


TASK(TaskBT) 
{
	// Otherwise there will be a deadlock !!			
	SetEvent(TaskM,EVENT_BT_FINISHED);
	while(1){
		WaitEvent(EVENT_BT_START);
		ClearEvent(EVENT_BT_START);
		ecrobot_send_bt_packet((void *) swp_data,sizeof(int)*51);
		SetEvent(TaskM,EVENT_BT_FINISHED);
	};
	TerminateTask();

}

void ecrobot_device_initialize()
{
	ecrobot_init_bt_slave("TEOBALD");
}


void ecrobot_device_terminate(void)
{
	nxt_motor_set_speed(NXT_PORT_A,0,0);
	nxt_motor_set_speed(NXT_PORT_B,0,0);
  	ecrobot_term_bt_connection();
}


int deadzone_off(int d_in)
{
	int d_out = 0;
	if(d_in > 0){
		d_out = d_in + NXT_MOTORS_DEADZONE;
	}
	else if(d_in < 0){
		d_out = d_in - NXT_MOTORS_DEADZONE;
	}
	else{
		d_out = d_in;
	}
	return d_out;
}

int get_value(int start_value,int step_size,char * name,int num){
	int wait = 1;
	int r = start_value;
	while(ecrobot_is_ENTER_button_pressed()){};
	nxt_motor_set_count(NXT_PORT_A,0);
	display_clear(0);
	display_goto_xy(0,2);
	display_string(name);
	display_int(num,1);
	display_goto_xy(0,3);
	display_string("step s:");
	display_int(step_size,4);
	while(wait){
		display_goto_xy(2,6);
		display_int(r,8);
		display_update();
		r = (start_value + ecrobot_get_motor_rev(NXT_PORT_A)/ 5*step_size);
		if(ecrobot_is_ENTER_button_pressed()){
			wait = 0;
		}
		systick_wait_ms(50);
	}
	return r;
}



int init_gyro(int gyro_port)
{


	// Wait for either enter to be pressed or an array of faults send
	int wait = 1;	
	F_A_S_T[0] = get_value(2000,500,"FT",0);	
	F_A_S_T[1] = get_value(6000,500,"FT",1);	
	int i;
	for(i = 0;i<3;i++){
		F_S_GAIN[i] = get_value(100,1,"FSG e-2|",i)/100.0F;
	}
	for(i = 0;i<3;i++){
		F_S_OFFSET[i] = get_value(0,1,"FSO|",i);
	}
	for(i = 0;i<3;i++){
		F_S_DRIFT[i] = get_value(0,1,"FSD e-2|",i)/100.0F;
	}
	for(i = 0;i<2;i++){
		F_A_GAIN[i] = get_value(10,1,"FAG e-1|",i)/10.0F;
	}
	for(i = 0;i<2;i++){
		F_A_OFFSET[i] = get_value(0,1,"FAO|",i);
	}

	// Wait for button to be pressed to start gyro init
	display_fault_values();
	wait = 1;
	while(ecrobot_is_ENTER_button_pressed()){};
	while(wait){
		if(ecrobot_is_ENTER_button_pressed()){
			wait = 0;
		}
	};
	disp_message("init gyro...");
	ecrobot_sound_tone(700,500,50);
	systick_wait_ms(1000);
	int offsets = 0;
	for(i = 0; i < 1000; i++){
		offsets += ecrobot_get_gyro_sensor(gyro_port);
	}
	int offset = offsets/1000;
	disp_message("Finished init gyro");
	ecrobot_sound_tone(700,500,50);
	systick_wait_ms(2000);
	return offset;
}	

void display_fault_values(){
	display_clear(0);
	display_goto_xy(0,0);
	display_string("F_T:");
	display_int(F_A_S_T[0],4);
	display_string(";");
	display_int(F_A_S_T[1],4);

	int i;
	display_goto_xy(0,1);
	display_string("FSG:");
	for(i =0 ; i < 3;i++){
		display_int( F_S_GAIN[i]*10,3);
		display_string(";");
	};
	display_goto_xy(0,2);
	display_string("FS0:");
	for(i=0; i < 3;i++){
		display_int( F_S_OFFSET[i],3);
		display_string(";");
	};
	display_goto_xy(0,3);
	display_string("FSD:");
	for(i=0; i < 3;i++){
		display_int( F_S_DRIFT[i]*100,4);
		display_string(";");
	};
	display_update();
	display_goto_xy(0,4);
	display_string("FAG:");
	for(i =0 ; i < 2;i++){
		display_int( F_A_GAIN[i]*10,3);
		display_string(";");
	};
	display_goto_xy(0,5);
	display_string("FA0:");
	for(i=0; i < 2;i++){
		display_int( F_A_OFFSET[i],3);
		display_string(";");
	};


}



/* Display and init function */
void disp_message(char * mesg)
{
	display_clear(0);
	display_goto_xy(0,4);
	display_string(mesg);
	display_goto_xy(0,5);
	display_update();
}





