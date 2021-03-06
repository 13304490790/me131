%Nitin Kapania
%Code for HW 7, Problem 1
clear all; close all; clc;

%%
%Part a)
clear all ; clc;

Wf = .57;
m = 1650; %mass, in kg
Cf = 200000; %Front cornering stiffness, N/rad
Cr = 200000; %Rear cornering stiffness, N/rad
L = 2.468; %Vehicle lengthgth, meters
a = (1-Wf)*L; %Distance from CG to front, m
b = Wf*L; %Distance from CG to rear, m
Iz = 2235; %Vehicle rotational inertia, kg m^2
g = 9.81;  %gravity acceleration, meters/sec^2
FzF = m*b*g/L; %Normal force on front tire
FzR = m*a*g/L; %Normal force on rear tire
Kug = (FzF/Cf - FzR/Cr)/g;

kp = 0;

% define the coefficients of the A matrix
c0 = Cf + Cr;
c1 = a*Cf - b*Cr;
c2 = (a^2)*Cf + (b^2)*Cr;

vars = [c0, c1, c2, Iz, Cf, m, a];

%A matrix for Ux = 10,20
% cl_dynamics(Ux, kp, x_LA, vars)
% simplifies to the open loop dynamics with kp = x_LA = 0

A10 = cl_dynamics(10, 0, 0, vars);
A20 = cl_dynamics(20, 0, 0, vars);

% Poles for Ux = 10,20
p10 = eig(A10)
p20 = eig(A10)

plot(p10,'ko','MarkerSize',8,'MarkerFaceColor','k');
hold on; grid on; axis equal; 
xlabel('Real','FontSize',14);
ylabel('Imag','FontSize',14);
plot(p20,'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Ux = 10 m/s','Ux = 20 m/s');

%%
%Part b)
clc;

kp = 1*pi/180; %rad/m = 0.0174
Ux = [5; 10; 15; 20; 25; 30];
c  = ['r', 'g', 'b', 'k', 'm', 'c'];

figure; hold on; grid on;
xlabel('Real','FontSize',14);
ylabel('Imag','FontSize',14);


for i = 1:length(Ux)
    
    A = cl_dynamics(Ux(i), kp, 0, vars);
    poles = eig(A)
    plot(poles,[c(i) 'o'], 'MarkerSize', 8, 'MarkerFaceColor',c(i));
    leg(i) = {['Ux = ' num2str(Ux(i)) ' m/s']};
    
end

legend(leg);

%%
%Part c)
clc;

kp = 1*pi/180; %rad/m
Ux = 25;
xLA = [1; 10; 20; 100]; %m
c  = ['r', 'g', 'b', 'k'];

figure; hold on; grid on; axis equal;
xlabel('Real','FontSize',14);
ylabel('Imag','FontSize',14);

for i = 1:length(xLA)
    A = cl_dynamics(Ux, kp, xLA(i), vars);
    poles = eig(A);
    plot(poles,[c(i) 'o'], 'MarkerSize', 8, 'MarkerFaceColor',c(i));
    leg(i) = {['xLA = ' num2str(xLA(i)) ' m']};
    
end

legend(leg);
    

xLA = 20:5:100; %m
figure; hold on; grid on; axis equal;
xlabel('Real','FontSize',14);
ylabel('Imag','FontSize',14);

for i = 1:length(xLA)
    A = cl_dynamics(Ux, kp, xLA(i), vars);
    poles = eig(A);
    plot(poles,'kx', 'MarkerSize',14);
end

%%
%Part d)
clear all; clc;

kp = 1*pi/180; Ux = 25;
xLA = [10 15 20 100];
figure; hold on; grid on;
xlabel('time (s)','FontSize',14);
ylabel('Lateral Error (m)','FontSize',14);

c = ['r', 'g', 'b', 'k'];

for i = 1:length(xLA)
    [t, e, dPsi, r, Uy] = bikesim(Ux, kp, xLA(i), 'lin');
    plot(t, e, c(i), 'LineWidth',2)
    leg(i) = {['xLA = ' num2str(xLA(i)) ' m']};
end


legend(leg);