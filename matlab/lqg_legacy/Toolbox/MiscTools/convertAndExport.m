function convertAndExport(reg)

this_dir = pwd;
cd ../../Hipster_sw/TillPres/Hipster_gcc_utils 
sys2gcc(reg, 'lq_servo_sys_new');
cd ../Hipster_gcc
system('make flash');
cd(this_dir);