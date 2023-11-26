classdef Synthesis <handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataSeries;
    end
    
    methods
        
        function setDataSeries(obj, l_dataSeries)
            obj.dataSeries = l_dataSeries;
        end
        
        
        function makeDynamics(obj, l_duration)
           l_data = randn(1,l_duration);
           obj.dataSeries.setNoise(l_data);
           s = tf('s');
           l_Tconst = obj.dataSeries.getTimeConstant();
           l_sys = sqrt(l_Tconst*2)/(1+l_Tconst*s);
           l_data = lsim(l_sys,l_data,1:l_duration);
           obj.dataSeries.setDynamicNoise(l_data);
        end
        
        function makeCorrelatedDynamics(obj, l_referenceData)%BIG TODO
            l_duration = length(l_referenceData);
            l_data = randn(1,l_duration);
            l_correlation = obj.dataSeries.getParameter();
            l_correlation = l_correlation.correlation;
            l_data = (l_correlation*l_referenceData + l_data)/(l_correlation+1);
            
            obj.dataSeries.setNoise(l_data);
            s = tf('s');
            l_Tconst = obj.dataSeries.getTimeConstant();
            l_sys = sqrt(l_Tconst*2)/(1+l_Tconst*s);
            l_data = lsim(l_sys,l_data,1:l_duration);
            obj.dataSeries.setDynamicNoise(l_data);
        end
           
        function addTimeDependency(obj)
            l_data = obj.dataSeries.getDynamicNoise();
            
            l_mean = obj.dataSeries.getMean();
            l_mean = kron(ones(length(l_data)/8760,1),l_mean(:,1));
            
            
            l_stdDev = obj.dataSeries.getStdDeviation();
            l_stdDev = kron(ones(length(l_data)/8760,1),l_stdDev(:,1));
            
            l_data = l_data.*l_stdDev + l_mean;
            
            obj.dataSeries.setTimevariantNoise(l_data);
        end
        
    end
    
end

