% linsim

for i = 1:10
    
    % Scaling matrices  
    [Du Dz] = getScaleMtrx(cs); 
                                                            
    % Designvariables to Kalman filter
    R1 = diag([1 1]);
    R2 = 1E-6*diag([10 10 1]);    
    
    % Designvariables to LQ
    Q1 = (Dz\diag([1 1 i*10])/Dz);
    Q2 = (Du\diag([1 1])/Du);

    % Sampling period
    Ts = 1E-3;                   

    % LQG servo controller
    [regc, regd] = lqg_servo(cs, R1, R2, Q1, Q2, Ts);

    ds = cs; %c2d(cs,Ts);

    reg = regc;
    Go = ds({'y','z'},'u')*reg;
    Gc = feedback(Go,eye(3),reg.inputgroup.y,ds({'y','z'},'u').outputgroup.y,1);

    n = 1000;
    ref = zeros(3,n);
    ref(3,20:end)=0.1;
    ref = ref';
    t = (0:n-1)*Ts;


    lsim(Gc('z','r'),ref,t)

    eGo(:,i) = real(pole(Gc('z','r')));
end

plot(eGo.')

