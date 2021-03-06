% this is a test script, essentially unreadable, for experimenting with the
% data pulled off the barc.

%% Task 1
% obtain a transfer function for PWM to velocity
load('ID_rosbags/matFiles/speedID_1.mat');
PWM_timeseries = sig{10}; % motor PWM time series

startT = PWM_timeseries.TimeInfo.start; % start time of the time series object
endT = PWM_timeseries.TimeInfo.end;

timeLength = endT - startT;
timeStep = [1:398];

figure()
plot(PWM_timeseries) % the time series with unix time

figure()
plot(timeStep, PWM_timeseries.Data) % the time series with time steps

encoder_FL = sig{12};
encoder_FR = sig{13};
encoder_BL = sig{14};
encoder_BR = sig{15};

% figure()
% hold on 
% plot(encoder_FL)
% plot(encoder_FR)
% plot(encoder_BL) % the BL encoder is not working at all
% plot(encoder_BR)
% hold off
% arbitrarily choose one of the working encoders to use, FL
enc_FL_data = encoder_FL.Data;
enc_FL_time = encoder_FL.Time;

% resampling the PWM timeseries to match the time vector for the encoder
resampled_PWM = resample(PWM_timeseries, enc_FL_time);

enc_FL_startT = encoder_FL.TimeInfo.Start
enc_FL_endT = encoder_FL.TimeInfo.End
enc_FL_timeInterval = encoder_FL.TimeInfo.Length

% the actual time of the experiment in seconds
interval = (enc_FL_endT - enc_FL_startT)*10^-9 % seconds

% frequency of encoder data
freq = length(enc_FL_data)/interval % clocks per second
time_step = 1/freq % time steps for encoder data, in seconds

realTime = [0:time_step:interval-time_step]';

% now convert encoder angular displacement to vehicle long. velocity
WHEEL_RAD = 0.1 / 2.0; % wheel radius in meters

% encoder counts converted to wheel radians
RAD_PER_ENC = pi/4; % each encoder count is 1/8th of a revolution

% angular displacement of wheel in radians
ang_displacement = enc_FL_data.*RAD_PER_ENC

figure()
plot(realTime, ang_displacement)

% numerically differentiate the angular displacement

enc_diff = diff(enc_FL_data);
ang_vel = enc_diff./time_step % wheel angular vel. in rad/s

% the longitudinal velocity 
long_velocity = WHEEL_RAD*ang_vel;

% rectified real time vector to match vector sizes
rec_realTime = realTime(1:end-1);

% figure()
% plot(rec_realTime, long_velocity)

% the numerical differentiation is noisy so we apply a moving average
figure()
smooth_vel = smoothdata(long_velocity);
plot(rec_realTime, smooth_vel);

% bring in the x-axis acclerometer data
accel_x_sig = sig{7};
accel_x = accel_x_sig.Data;

figure()
plot(smoothdata(accel_x))
% this looks like garbage, we can try numerical differentiation of the
% encoder again
vel_diff = diff(smooth_vel);
long_accel = vel_diff./time_step;

rerec_realTime = realTime(1:end-2); % twice rectified time data for accel
figure()
smooth_accel = smoothdata(long_accel);
plot(rerec_realTime, smooth_accel);
% twice differentiated encoder data is way nicer than accelerometer data

% construct the matrices for least squares
smooth_accel; % length 202
size(smooth_vel); % length 203
size(resampled_PWM.Data); % 204

% resize vectors to match, had to remove the ends of the vector to avoid
% NaNs from showing up in the PWM signal
res_smooth_accel = smooth_accel(1:end-60);
res_smooth_vel = smooth_vel(1:end-61);
res_resampled_PWM = resampled_PWM.Data(1:end-62);

size(res_smooth_accel);
size(res_smooth_vel);
size(res_resampled_PWM);

vdot = res_smooth_accel;
v = [res_smooth_vel, res_resampled_PWM];
size(v);

w = v\vdot % perform least squares to obtain coefficients for a TF

% TODO: bring in four other experiments accleration data to include in the
% least squares approximation of these parameters
% TODO: clean up this code with functions, remove what's unnecessary
