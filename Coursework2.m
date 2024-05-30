%Jiyun_Feng_20513510
%ssyjf3@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

a = arduino; %Initialize the Arduino Uno Board

for i = 1:5 %Execute 5 times
    writeDigitalPin(a, 'd13', 1); %Set the Digital Pin 13 HIGH
    pause(1); %Keep 0.5s
    writeDigitalPin(a, 'd13', 0); %Set the Digital Pin 13 LOW
    pause(1); %Keep 0.5s
end 

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

a = arduino; %Initialize the Arduino Uno Board

va=linspace(0,0,601); %Set a empty array to store the voltage read
i=1; %Counter for second
while 1 %Waiting for 10mins
    v=a.readVoltage('A0'); %Read the voltage on the Analog Pin 0
    pause(1); %Wait for 1s;
    va(i)=v; %Assign the values in order into the array
    i=i+1; %Shift the counter
    if i == 602 %Exit the loop after 10mins' measurements
        break; %Break the infinite loop
    end
end

T=(va-0.5)/0.01; %Convert the voltage to temperature, Tc = 10mV/deg. T_0deg = 500mV
t=1:1:601; %Set the time (s)
Tavg=mean(T); %Get the average of the temperature measured
Tmax=max(T); %Get the maximum of the temperature measured
Tmin=min(T); %Get the minimum of the temperature measured
plot(t,T); %Plot the graph T-t
xlabel("Time (s)");
ylabel("Temperature (\circC)");
xlim([0 601]);

fp = fopen("cabin_temperature.txt", "w"); %Open the file as written
fprintf(fp, "Data logging initiated - 5/4/2024\nLocation - Nottingham\n\n"); %Write the title of the file
for i = 0:10 %Print the data of Minute 0 to Minute 10
    t_txt = sprintf("Minute\t\t\t%d\n", i); %Use format specifier to assign the Minute to a string
    T_txt = sprintf("Temperature\t\t%.2f C\n",T(i*60+1)); %Use format specifier to assign the Temperature to a string
    fprintf(fp, t_txt); %Write the format specifier of the Minute
    fprintf(fp, T_txt); %Write the format specifier of the Temperature 
    fprintf(fp, "\n");
end
fprintf(fp, "Max temp\t\t%.2f C\nMin temp\t\t%.2f C\nAverage temp\t%.2f C\n\nData logging terminated", Tmax, Tmin, Tavg);
fclose(fp);
fp = fopen("cabin_temperature.txt", "r"); %Read the file
fcontent = fscanf(fp, "%s"); %Get the strings in the file
disp(fcontent); %Print the read content in the command window

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

figure;

va=linspace(0,0,601); %Set a empty array to store the voltage read
T=linspace(0,0,601);
i=1; %Counter for second

while true
    v=a.readVoltage('A0'); %Read the voltage on the Analog Pin 0
    va(i)=v; %Assign the values in order into the array
    
    if i == 602 %Exit the loop after 10mins' measurements
        break; %Break the infinite loop
    end
    T(i)=(va(i)-0.5)/0.01; %Convert the voltage to temperature, Tc = 10mV/deg. T_0deg = 500mV
    t=1:1:601; %Set the time (s)
    Tavg=mean(T); %Get the average of the temperature measured
    Tmax=max(T); %Get the maximum of the temperature measured
    Tmin=min(T); %Get the minimum of the temperature measured
    plot(t,T); %Plot the graph T-t
    xlabel("Time (s)");
    ylabel("Temperature (\circC)");
    title("Real Temperature Plot");
    drawnow;
    xlim([0 601]);
    if T(i) <= 24 && T(i) >= 18
        writeDigitalPin(a, 'd11', 0);
        writeDigitalPin(a, 'd12', 0);
        
        writeDigitalPin(a, 'd13', 1); %Set the Digital Pin 13 (Green) High constantly
        pause(2);
    end
    if T(i) < 18
        writeDigitalPin(a, 'd13', 0);
        writeDigitalPin(a, 'd12', 0);

        writeDigitalPin(a, 'd11', 1); %Set the Digital Pin 11 (Yellow) HIGH
        pause(1); %Keep 0.5s
        writeDigitalPin(a, 'd11', 0); %Set the Digital Pin 11 (Yellow) LOW
        pause(1); %Keep 0.5s
    end
    if T(i) > 24
        writeDigitalPin(a, 'd13', 0);
        writeDigitalPin(a, 'd11', 0);

        writeDigitalPin(a, 'd12', 1); %Set the Digital Pin 12 (Red) HIGH
        pause(0.5); %Keep 0.25s
        writeDigitalPin(a, 'd12', 0); %Set the Digital Pin 12 (Red) LOW
        pause(0.5); %Keep 0.25s
    end
    i=i+1; %Shift the counter
end

%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]
function temp_prediction
n=1;
data=1; %current data
count=1;
while n>2
    v=a.readVoltage('A0'); %Read the voltage on the Analog Pin 0
    temperature=(v-0.5)/0.01/Tc; %The relationship between temperature and voltage
    data(count)=temperature;
    if count>1
        rate=data(count)-data(count-1);%the rate of change in temperature
        fprintf('The rate of change in temperature is %.2f°C/s',rate)
        if rate>4 %When the rate of change in temperature > 4, a constant Red LED 
        writeDigitalPin(a, 'd13', 0); %The Green LED is off
        writeDigitalPin(a, 'd11', 0); %The Yellow LED is off

        writeDigitalPin(a, 'd12', 1); %Set the Digital Pin 12 (Red) HIGH
        end
        if rate>-4 %When the rate of change in temperature > -4, a constant Yellow LED
        writeDigitalPin(a, 'd13', 0); %The Green LED is off
        writeDigitalPin(a, 'd12', 0); %The Red LED is off

        writeDigitalPin(a, 'd11', 1); %Set the Digital Pin 11 (Yellow) HIGH
        end
        if (-4<rate)<4 % When the rate of change in temperature belong -4 to 4, a constant Green LED
        writeDigitalPin(a, 'd11', 0);
        writeDigitalPin(a, 'd12', 0);
        
        writeDigitalPin(a, 'd13', 1); %Set the Digital Pin 13 (Green) High constantly
        end
        predict_temperature=data(count)+rate*300; %Predict the temperature and 300=5min*60s/min
    end
end
end

%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% In the second task, it was difficult to observe the light emitted by the three LEDs,
% as the ambient temperature is generally around 20°C (usually only the green light is on), 
% and the outside temperature needs to be raised or lowered to observe changes in the other lights. 
% For example, the temperature is adjusted by the air conditioner and the thermistor is heated by hand. 
% In the third task, the rate of change in temperature was expressed by the luminescence of the LEDs, 
% but in most cases only the green light was on, 
% because it was difficult to increase the thermistor by more than 4 degrees per minute (the red light was not on) even if the thermistor was heated by hand, 
% and the suggestion for the improvement of the project was to replace the thermistor with a more temperature-sensitive one, 
% so that the different states of the three LEDs could be observed.