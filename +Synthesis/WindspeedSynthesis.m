classdef WindspeedSynthesis  < Synthesis.Synthesis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xN2W;
        yN2W;
    end
    
    methods
        function obj = WindspeedSynthesis()
            obj.xN2W = -5.02:0.02:5;
            obj.xN2W(1) = -12;
            obj.xN2W(end) = 8.3;
            obj.yN2W = -log(0.5-0.5*erf(obj.xN2W/sqrt(2)));
            obj.yN2W(1) = 0;
        end
            
        function Transform(obj)
            l_data = obj.dataSeries.getTimevariantNoise();
            l_mean = mean(l_data);
            l_stdDev = std(l_data);
            l_kappa = l_mean/l_stdDev;
            l_lambda = 1/l_mean;
            obj.dataSeries.setSyntData(interp1(l_stdDev*obj.xN2W+l_mean,nthroot(obj.yN2W,l_kappa)/l_lambda,obj.dataSeries.getTimevariantNoise()));
        end

    end
    
end
