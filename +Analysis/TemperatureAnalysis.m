classdef TemperatureAnalysis  < Analysis.Analysis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = TemperatureAnalysis()
            obj.ysensitivity = 0*(-50:50)+1;
            obj.xsensitivity = (-50:50);
        end
        
        function backTrafo(obj)
            obj.dataSeries.setMeasurementNormal(obj.dataSeries.getMeasurement);
        end
        

    end
    
end

