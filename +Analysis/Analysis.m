classdef Analysis < handle
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataSeries;
        xsensitivity;
        ysensitivity;
    end
    
    methods
        
        function setDataSeries(obj, l_dataSeries)
            obj.dataSeries = l_dataSeries;
        end
        
        function analyzeMean(obj)
            l_data = obj.dataSeries.getMeasurementNormal();
            l_data = reshape(l_data,8760,length(l_data)/8760); 
            l_mean = mean(l_data,2);
            obj.dataSeries.setMeasurementMean(l_mean);
            
            obj.dataSeries.setMeasuredWeight(interp1(obj.xsensitivity, obj.ysensitivity, l_mean));
            clc
            [l_par, l_mean] = obj.analyze6ParamPlane(obj.dataSeries.getMeasuredWeight(),l_mean);
            l_parameter.mean.phid = l_par(1);
            l_parameter.mean.phiy = l_par(2);
            l_parameter.mean.A0 = l_par(3);
            l_parameter.mean.Ad = l_par(4);
            l_parameter.mean.Ay = l_par(5);
            l_parameter.mean.Ady = l_par(6);
            obj.dataSeries.addParameters(l_parameter);
            obj.dataSeries.setWeight(interp1(obj.xsensitivity, obj.ysensitivity, l_mean(:,2)));% ((1:1:8760) -0.5)',
            obj.dataSeries.setMean(l_mean(:,2));
        end

        function [l_par, l_simData] = analyze6ParamPlane(~,l_weightfun,l_data)
            l_WD = 2*pi/24;
            l_WY = 2*pi/8760;
            l_data = l_data(:);
            l_TS = 1;
            l_T = ((1:l_TS:8760) -0.5*l_TS)';
            %p: 1 phid; 2phiy; 3 Acons; 4 Aday; 5 Ayear; 6 Adayyear
            l_function = @(p) p(3) + p(4)*cos(l_WD.*l_T-p(1)) + p(5)*cos(l_WY.*l_T-p(2)) + p(6)*cos(l_WD.*l_T-p(1)).*cos(l_WY.*l_T-p(2));
            l_costfun = @(p) sum((l_data - l_function(p)).^2.*l_weightfun(:));
            %compute estimate of l_p0:
            l_p0 = [pi, pi, 0,0,0,0]';
            %fourierRowParameters:
            l_ay = sum(l_data.*cos(l_WY*l_T))/pi;
            l_by = sum(l_data.*sin(l_WY*l_T))/pi;
            l_ad = sum(l_data.*cos(l_WD*l_T))/pi/365;
            l_bd = sum(l_data.*sin(l_WD*l_T))/pi/365;
            l_p0(1) = atan2(l_bd,l_ad);
            l_p0(2) = atan2(l_by,l_ay);
            l_p0(3) = sum(l_weightfun.*l_data)./sum(l_weightfun); %no further optimization
            l_p0(4) = sqrt(l_ad^2+l_bd);
            l_p0(5) = sqrt(l_ay^2+l_by);
            l_p0(6) = fminsearch(@(p) l_costfun([l_p0(1:5);p]),0,optimset('MaxFunEvals',1e10));

            %l_p0(3) = sum(l_weightfun.*l_data)./sum(l_weightfun); %no further optimization
            %l_p0(4) = fminsearch(@(p) l_costfun([l_p0(1:3);p;l_p0(5:6)]),0,optimset('MaxFunEvals',1e10));
            %l_p0(5) = fminsearch(@(p) l_costfun([l_p0(1:4);p;l_p0(6)]),0,optimset('MaxFunEvals',1e10));
            %l_p0(6) = fminsearch(@(p) l_costfun([l_p0(1:5);p]),0,optimset('MaxFunEvals',1e10));
            
            l_dataD = sum(reshape(l_weightfun.*l_data,24,365))./sum(reshape(l_weightfun,24,365));
            l_TD = sum(reshape(l_T,24,365))/24/24;
            l_ay = sum(l_dataD.*cos(l_WY*24*l_TD))*2/365;
            l_by = sum(l_dataD.*sin(l_WY*24*l_TD))*2/365;
            l_p0(2) = atan2(l_by,l_ay);
            l_p0(5) = sqrt(l_by^2+l_ay^2);
            l_p0(3) = mean(l_data);%sum(l_weightfun.*l_data)./sum(l_weightfun);

            l_ad = sum(l_data(1:96).*cos(l_WD*l_T(1:96)))/pi/4;
            l_bd = sum(l_data(1:96).*sin(l_WD*l_T(1:96)))/pi/4;
            l_p0(1) = atan2(l_bd,l_ad);
            l_p0(4) = fminsearch(@(p) l_costfun([l_p0(1:3);p;l_p0(5);0]),l_p0(5),optimset('MaxFunEvals',1e10));
            l_p0(4) = fminsearch(@(p) l_costfun([l_p0(1:3);p;l_p0(5);0]),l_p0(5),optimset('MaxFunEvals',1e10));
            l_p0(6) = fminsearch(@(p) l_costfun([l_p0(1:5);p]),0,optimset('MaxFunEvals',1e10));
            
            l_p0(1) = pi;
            l_p0(2) = pi;
            l_p0([3,5]) = fminsearch(@(p) l_costfun([l_p0(1:2);p(1);0;p(2);0]),[0;0],optimset('MaxFunEvals',1e10));
            l_p0([4,6]) = fminsearch(@(p) l_costfun([l_p0(1:3);p(1);l_p0(5);p(2)]),[0;0],optimset('MaxFunEvals',1e10));
            
            l_par = fminsearch(l_costfun,l_p0,optimset('MaxFunEvals',1e10))%,optimset(%'Display','iter','PlotFcns',@optimplotfval,'MaxFunEvals',1e6));
            l_simData = l_function(l_par);
            l_simData = [l_T(:), l_simData(:)];
        end
        
        function analyzeStdDeviation(obj)
            l_data = obj.dataSeries.getMeasurementNormal();
            l_data = reshape(l_data,8760,length(l_data)/8760); 
            l_stdDeviation = sqrt(mean((l_data-kron(ones(1,length(l_data)/8760),mean(l_data,2))).^2,2));
            obj.dataSeries.setMeasurementStdDeviation(l_stdDeviation);
            [l_par, l_stdDeviation] = obj.analyze6ParamPlane(obj.dataSeries.getMeasuredWeight(),l_stdDeviation);
            l_parameter.stdDev.phid = l_par(1);
            l_parameter.stdDev.phiy = l_par(2);
            l_parameter.stdDev.A0 = l_par(3);
            l_parameter.stdDev.Ad = l_par(4);
            l_parameter.stdDev.Ay = l_par(5);
            l_parameter.stdDev.Ady = l_par(6);
            obj.dataSeries.addParameters(l_parameter);
            obj.dataSeries.setStdDeviation(l_stdDeviation(:,2));
        end
        
        function compensateTimeDependency(obj)
            l_data = obj.dataSeries.getMeasurementNormal();
            l_mean = kron(ones(length(l_data)/8760,1),obj.dataSeries.getMeasurementMean());
            l_stdDeviation = kron(ones(length(l_data)/8760,1),obj.dataSeries.getMeasurementStdDeviation());
            l_data = (l_data - l_mean)./(l_stdDeviation + (l_stdDeviation==0));
            obj.dataSeries.setTCompensatedData(l_data);
        end
        
        function analyzeTimeConstant(obj)
            l_data = obj.dataSeries.getTCompensatedData();
            l_TS = 1;
            l_T = ((1:l_TS:8*8760) -0.5*l_TS)';
            l_weight = obj.dataSeries.getMeasuredWeight();
            [f,A] = fourier(l_T(logical(~(kron(ones(8,1),l_weight)<0.001))),l_data(logical(~(kron(ones(8,1),l_weight)<0.001))));
            w = [2*pi*f(1:13) 2*pi*f(14:4:end)];
            A=A*sqrt(length(A));
            A = [A(1:13) A(14:4:end)];
            logw = log(w(logical(log(w)<-0.7 & log(w)>-1.0)));
            logA = log(A(logical(log(w)<-0.7 & log(w)>-1.0)));
            b = mean(logw+logA);
            T = 2/(exp(2*b));
            obj.dataSeries.setTimeConstant(T);
        end
        
        function analyzeCorrelation(obj,l_referenceDataSeries)
            s = tf('s');
            l_data = obj.dataSeries.getTCompensatedData();
            l_dataRef = l_referenceDataSeries.getTCompensatedData();
            l_tConst = obj.dataSeries.getTimeConstant();
            l_tConstRef = l_referenceDataSeries.getTimeConstant();
            l_filter = sqrt(l_tConst/l_tConstRef) * ((1+l_tConstRef*s)/(1+l_tConst*s));
            l_dataRef = lsim(l_filter, l_dataRef, 0:length(l_dataRef)-1);
            l_cov = (sum(kron(ones(8,1),obj.dataSeries.getMeasuredWeight()).*l_data .* l_dataRef))/(8*sum(obj.dataSeries.getMeasuredWeight()));
            l_correlation = l_cov/(1-l_cov);
            obj.dataSeries.setCorrelation(l_correlation);
        end
        
        
        
    end
end

