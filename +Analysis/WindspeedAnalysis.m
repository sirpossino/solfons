classdef WindspeedAnalysis  < Analysis.Analysis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xN2W;
        yN2W;
    end
    
    methods
        function obj = WindspeedAnalysis()
            obj.xN2W = -5.02:0.02:5;
            obj.yN2W = -log(0.5-0.5*erf(obj.xN2W/sqrt(2)));
            obj.yN2W(1) = 0;
            
            
            
            
        end
        
        function backTrafo(obj)
            l_data = obj.dataSeries.getMeasurement();
            l_mean = mean(l_data);
            l_stdDev = std(l_data);
            l_kappa = fzero(@(k) l_stdDev * gamma(1+1/k) - l_mean * sqrt(gamma(1+2/k)-gamma(1+1/k)^2),3);
            l_lambda = gamma(1+1/l_kappa)/l_mean;
            
            obj.dataSeries.setMeasurementNormal( interp1(obj.yN2W,obj.xN2W,(l_lambda.*l_data).^l_kappa)/l_lambda/l_kappa + 1/l_lambda );
            
            
            obj.xsensitivity = ((obj.xN2W(1:end-1)/l_lambda/l_kappa + 1/l_lambda)+(obj.xN2W(2:end)/l_lambda/l_kappa + 1/l_lambda))/2;
            obj.ysensitivity = l_kappa*((nthroot(obj.yN2W(1:end-1),l_kappa)-nthroot(obj.yN2W(2:end),l_kappa))./(obj.xN2W(1:end-1)-obj.xN2W(2:end)));
        end
        

    end
    
end

