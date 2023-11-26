if(~adjust)
close all
clear
adjust = 0;
%generate the overall set of different models
models = Model.ModelSet();
end
%%
% Zeitreihenobjekte generieren und abspeichern, sowie
% Zeitreihenverwaltung
if(~adjust)
run('./RawData/generateDescriptions.m')
for i = 1:length(ADDRESS)
    %load raw data
    load(strcat('./RawData/',ADDRESS(i).text));
    
    
    %generate Data objects
    irradiation = Data.Irradiation();
   % irradiation = [irradiation(), irradiation()]
    temperature = Data.Temperature();
    wind = Data.Wind();
    
    irradiationData = irradiationData(:);
    temperatureData = temperatureData(:);
    windData = windData(:);
    
    
    ShiftDays = mod(length(irradiationData)-round(LONGITUDE(i)*24/360),length(irradiationData));
    irradiationData_ = [irradiationData(ShiftDays+1 : end); irradiationData(1:ShiftDays)];
    temperatureData_ = [temperatureData(ShiftDays+1 : end); temperatureData(1:ShiftDays)];
    windData_ = [windData(ShiftDays+1 : end); windData(1:ShiftDays)];
    
    
    
    %set values
    SAMPLING = 3600; %s
    irradiation.defineMeasurement(1000*irradiationData_,SAMPLING);
    temperature.defineMeasurement(temperatureData_,SAMPLING);
    wind.defineMeasurement(windData_,SAMPLING);
    
    %generate location and add to models!
    location = Model.Location();
    location.setWeather(irradiation,temperature,wind);
    location.setName(NAME(i).text);
    location.setLatitude(LATITUDE(i));
    location.setLongitude(LONGITUDE(i));
    models.addLocation(location);
    
end
end
%%
% Analyse der Zeitreihen nach Methode xy
if(~adjust)
irradiationAnalysis = Analysis.IrradiationAnalysis(0.9);
temperatureAnalysis = Analysis.TemperatureAnalysis();
windspeedAnalysis = Analysis.WindspeedAnalysis();

for i = 1 : 16 %TODO
    location = models.getLocation(i); 
    irradiation = location.getIrradiation();
    irradiationAnalysis.setDataSeries(irradiation);
    irradiationAnalysis.backTrafo();
    irradiationAnalysis.analyzeMean();
    irradiationAnalysis.analyzeStdDeviation();
    irradiationAnalysis.compensateTimeDependency();
    irradiationAnalysis.analyzeTimeConstant();
    
    temperature = location.getTemperature();
    temperatureAnalysis.setDataSeries(temperature);
    temperatureAnalysis.backTrafo();
    temperatureAnalysis.analyzeMean();
    temperatureAnalysis.analyzeStdDeviation();
    temperatureAnalysis.compensateTimeDependency();
    temperatureAnalysis.analyzeTimeConstant();
    temperatureAnalysis.analyzeCorrelation(irradiation);
    
    windspeed = location.getWindspeed();
    windspeedAnalysis.setDataSeries(windspeed);
    windspeedAnalysis.backTrafo();
    windspeedAnalysis.analyzeMean();
    windspeedAnalysis.analyzeStdDeviation();
    windspeedAnalysis.compensateTimeDependency();
    windspeedAnalysis.analyzeTimeConstant();
    windspeedAnalysis.analyzeCorrelation(temperature);
end
end
%%
%Parameter Modifications
adjust = 1;
location = models.getLocation(3);temperature = location.getTemperature();irradiation = location.getIrradiation();windspeed = location.getWindspeed();
windspeed.setCorrelation(-0.323)%-0.2771  E200


location = models.getLocation(15);temperature = location.getTemperature();irradiation = location.getIrradiation();windspeed = location.getWindspeed();
windspeed.setCorrelation(-0.602)%-0.2023  E-530
windspeed.setTimeConstant(50)%6.3187  E500


%%
%Synthese der Zeitreihen nach Methode xy
irradiationSynthesis = Synthesis.IrradiationSynthesis(0.9);
temperatureSynthesis = Synthesis.TemperatureSynthesis();
windspeedSynthesis = Synthesis.WindspeedSynthesis();

for i = 1 : 16 %TODO
    location = models.getLocation(i); 
    irradiation = location.getIrradiation();
    irradiationSynthesis.setDataSeries(irradiation);
    irradiationSynthesis.makeDynamics(8*8760);
    irradiationSynthesis.addTimeDependency();
    irradiationSynthesis.Transform();
    
    temperature = location.getTemperature();
    temperatureSynthesis.setDataSeries(temperature);
    temperatureSynthesis.makeCorrelatedDynamics(irradiation.getNoise());
    temperatureSynthesis.addTimeDependency();
    temperatureSynthesis.Transform();
    
    windspeed = location.getWindspeed();
    windspeedSynthesis.setDataSeries(windspeed);
    windspeedSynthesis.makeCorrelatedDynamics(temperature.getNoise());
    windspeedSynthesis.addTimeDependency();
    windspeedSynthesis.Transform();
end

%%
% Evaluierung der Zeitreihen nach Methode xy

evaluation = Evaluation.Evaluation();

for i = 1 : 16 %TODO
    location = models.getLocation(i); 
    irradiation = location.getIrradiation();
    temperature = location.getTemperature();
    windspeed = location.getWindspeed();
    
    
    evaluation.setDataSeries(irradiation.getMeasurement(), irradiation.getSyntData());
    e.irradiation.pdf = evaluation.relPDF();
    e.irradiation.mean = evaluation.relMean();
    e.irradiation.stdDev = evaluation.relStdDev();
    e.irradiation.time = evaluation.relTime();

    evaluation.setDataSeries(temperature.getMeasurement(), temperature.getSyntData());
    e.temperature.pdf = evaluation.absPDF();
    e.temperature.mean = evaluation.relMean();
    e.temperature.stdDev = evaluation.relStdDev();
    e.temperature.time = evaluation.relTime();
    e.temperature.type = evaluation.relType(irradiation.getMeasurement(), irradiation.getSyntData());
    
    evaluation.setDataSeries(windspeed.getMeasurement(), windspeed.getSyntData());
    e.windspeed.pdf = evaluation.relPDF();
    e.windspeed.mean = evaluation.relMean();
    e.windspeed.stdDev = evaluation.relStdDev();
    e.windspeed.time = evaluation.relTime();
    e.windspeed.type = evaluation.relType(temperature.getMeasurement(), temperature.getSyntData());
    
    location.setErrorMeasure(e);
    E.irradiation.pdf(i) = e.irradiation.pdf;
    E.irradiation.mean(i) = e.irradiation.mean;
    E.irradiation.stdDev(i) = e.irradiation.stdDev;
    E.irradiation.time(i) = e.irradiation.time;
    
    E.temperature.pdf(i) = e.temperature.pdf;
    E.temperature.mean(i) = e.temperature.mean;
    E.temperature.stdDev(i) = e.temperature.stdDev;
    E.temperature.time(i) = e.temperature.time;
    E.temperature.type(i) = e.temperature.type;
    
    E.windspeed.pdf(i) = e.windspeed.pdf;
    E.windspeed.mean(i) = e.windspeed.mean;
    E.windspeed.stdDev(i) = e.windspeed.stdDev;
    E.windspeed.time(i) = e.windspeed.time;
    E.windspeed.type(i) = e.windspeed.type;
end

%%
% Darstellung der Zeitreihen nach Methode xy

% 
% for i = 1 : 16 %TODO
i=8;
    location = models.getLocation(i);
    
    irradiation = location.getIrradiation();    
    temperature = location.getTemperature();    
    windspeed = location.getWindspeed();
    
    figure(10)
    hold off
    plot(0.5:(8*8760-0.5),irradiation.getMeasurement())
    hold on
    plot(0.5:(8*8760-0.5),irradiation.getSyntData())
    title(strcat('Irradiation ',location.name));
    
    figure(20)
    hold off
    plot(0.5:(8*8760-0.5),temperature.getMeasurement())
    hold on
    plot(0.5:(8*8760-0.5),temperature.getSyntData())
    title(strcat('Temperature ',location.name));  
    
    figure(30)
    hold off
    plot(0.5:(8*8760-0.5),windspeed.getMeasurement())
    hold on
    plot(0.5:(8*8760-0.5),windspeed.getSyntData())
    title(strcat('Windspeed ',location.name));
    
%     pause
% end


%%
clc

for  i = 1:16
    i
    location = models.getLocation(i);
    temperature = location.getTemperature();
    irradiation = location.getIrradiation();
    windspeed = location.getWindspeed();
%     any(isnan(irradiation.getSyntData()))
%     any(isnan(temperature.getSyntData()))
%     any(isnan(windspeed.getSyntData()))
end
figure(1)
plot([E.irradiation.pdf*100;E.windspeed.pdf*100]')
legend('irradiation','windspeed');
title('pdf Error')
figure(2)
plot([E.irradiation.mean*100;E.temperature.mean*100;E.windspeed.mean*100]')
legend('irradiation','temperature','windspeed');
title('mean Error')
figure(3)
plot([E.irradiation.stdDev*100;E.temperature.stdDev*100;E.windspeed.stdDev*100]')
legend('irradiation','temperature','windspeed');
title('stdDev Error')
figure(4)
plot([E.irradiation.time*100;E.temperature.time*100;E.windspeed.time*100]')
legend('irradiation','temperature','windspeed');
title('time Error')
figure(5)
plot([E.temperature.type*100;E.windspeed.type*100]')
legend('temperature','windspeed');
title('type Error')
figure(6)
plot(E.temperature.pdf)
legend('temperature');
title('pdf Error')
% 
% i=3
% location = models.getLocation(i);
% irradiation = location.getIrradiation();    
% temperature = location.getTemperature();    
% windspeed = location.getWindspeed();
% figure(99)
% plot([sort(windspeed.getMeasurement()) sqrt((sort(windspeed.getSyntData())-sort(windspeed.getMeasurement())).^2)    ]);
% 
% 
% %modify windspeed
% windspeed.setCorrelation(windspeed.getParameter().correlation +0.4)
% 
% %synthesis
%     irradiation = location.getIrradiation();
%     irradiationSynthesis.setDataSeries(irradiation);
%     irradiationSynthesis.makeDynamics(8*8760);
%     irradiationSynthesis.addTimeDependency();
%     irradiationSynthesis.Transform();
%     
%     temperature = location.getTemperature();
%     temperatureSynthesis.setDataSeries(temperature);
%     temperatureSynthesis.makeCorrelatedDynamics(irradiation.getNoise());
%     temperatureSynthesis.addTimeDependency();
%     temperatureSynthesis.Transform();
%     
%     windspeed = location.getWindspeed();
%     windspeedSynthesis.setDataSeries(windspeed);
%     windspeedSynthesis.makeCorrelatedDynamics(temperature.getNoise());
%     windspeedSynthesis.addTimeDependency();
%     windspeedSynthesis.Transform();
% 
% %evaluation
%     evaluation.setDataSeries(irradiation.getMeasurement(), irradiation.getSyntData());
%     e.irradiation.pdf = evaluation.relPDF();
%     e.irradiation.mean = evaluation.relMean();
%     e.irradiation.stdDev = evaluation.relStdDev();
%     e.irradiation.time = evaluation.relTime();
% 
%     evaluation.setDataSeries(temperature.getMeasurement(), temperature.getSyntData());
%     e.temperature.pdf = evaluation.absPDF();
%     e.temperature.mean = evaluation.relMean();
%     e.temperature.stdDev = evaluation.relStdDev();
%     e.temperature.time = evaluation.relTime();
%     e.temperature.type = evaluation.relType(irradiation.getMeasurement(), irradiation.getSyntData());
%     
%     evaluation.setDataSeries(windspeed.getMeasurement(), windspeed.getSyntData());
%     e.windspeed.pdf = evaluation.relPDF();
%     e.windspeed.mean = evaluation.relMean();
%     e.windspeed.stdDev = evaluation.relStdDev();
%     e.windspeed.time = evaluation.relTime();
%     e.windspeed.type = evaluation.relType(temperature.getMeasurement(), temperature.getSyntData());
%     
%     location.setErrorMeasure(e);
%     E.irradiation.pdf(i) = e.irradiation.pdf;
%     E.irradiation.mean(i) = e.irradiation.mean;
%     E.irradiation.stdDev(i) = e.irradiation.stdDev;
%     E.irradiation.time(i) = e.irradiation.time;
%     
%     E.temperature.pdf(i) = e.temperature.pdf;
%     E.temperature.mean(i) = e.temperature.mean;
%     E.temperature.stdDev(i) = e.temperature.stdDev;
%     E.temperature.time(i) = e.temperature.time;
%     E.temperature.type(i) = e.temperature.type;
%     
%     E.windspeed.pdf(i) = e.windspeed.pdf;
%     E.windspeed.mean(i) = e.windspeed.mean;
%     E.windspeed.stdDev(i) = e.windspeed.stdDev;
%     E.windspeed.time(i) = e.windspeed.time;
%     E.windspeed.type(i) = e.windspeed.type;
% 
% 
