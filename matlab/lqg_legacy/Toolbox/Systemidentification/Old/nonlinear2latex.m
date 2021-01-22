


syms I_p J_m K_t K_b R_a B_m L I_J I_xx I_zz m_w m_b R g V_right V_left I_w W

syms x phi lambda x_dot phi_dot lambda_dot 
%syms x_phi_dot lambda_dot x_ddot phi_ddot lambda_ddot 


A1 = m_b + 2*(m_w + (J_m + I_w)/R^2);
A2 = 2/R^2 * (B_m + K_t*K_b/R_a);
A3 = m_b*L*cos(lambda)-2*J_m/R;
A4 = m_b*L*sin(lambda);
A5 = K_t/(R*R_a);
A6 = 2*(B_m + K_t*K_b/R_a)/R;

B1 = m_b*L*cos(lambda) - 2*J_m/R;
B2 = 2/R * (B_m + K_t*K_b/R_a);
B3 = m_b*L^2 + I_p + 2*J_m;
B4 = (m_b*L^2 + I_xx - I_J)*sin(lambda)*cos(lambda);
B5 = m_b*L*g*sin(lambda);
B6 = K_t/R_a;
B7 = 2*(B_m + K_t*K_b/R_a);

C1 = (2*(m_w + (I_w + J_m)/R^2)*W^2 + I_xx*sin(lambda)^2 + I_J*cos(lambda)^2 + m_b*L^2*sin(lambda)^2);
C2 = 2*(m_b*L^2 + I_xx - I_J)*sin(lambda)*cos(lambda);
C3 = 2*W^2/R^2 * (B_m + K_t*K_b/R_a);
C4 = W*K_t/(R*R_a);

%%
% x_dot_const = simplify(B3/(A1*B3-A3*B1)*(-(A2 + A3*B2/B3)));
% lambda_dot_const = simplify(B3/(A1*B3-A3*B1) * (A3*B4/B3 - A4)*lambda_dot^2 
% output1 = simplify(B3/(A1*B3-A3*B1)*(A3*B6/B3 + A5)*(V_right+V_left));

syms A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 B7 C1 C2 C3 C4 den
syms x phi lambda x_dot phi_dot lambda_dot V_right V_left
den = A1*B3-A3*B1;

x_ddot = 1/den * (-(A2*B3 + A3*B2)*x_dot + (A3*B7 +B3*A6)*lambda_dot - B3*A4*lambda_dot^2 - A3*B4*phi_dot^2 - A3*B5  + (A3*B6 + A5*B3)*(V_right+V_left)+A3*B5/B3);
    
phi_ddot = 1/C1*(-(C2*lambda_dot + C3)*phi_dot + C4*(V_right-V_left));
   
lambda_ddot = 1/den * ( (B1*A2 + A1*B2)*x_dot - (B1*A6 + A1*B7)*lambda_dot - B1*A4*lambda_dot^2 ...
         + A1*B4*phi_dot^2 + A1*B5 - (B1*A5 + A1*B6)*(V_right+V_left));
    
    
%%
y = [1/R W/R 0 0 0 0;
     1/R -W/R 0 0 0 0;
      0 0 0 0 0 1] * x;
  
  %y
  
