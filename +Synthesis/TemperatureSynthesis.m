classdef TemperatureSynthesis  < Synthesis.Synthesis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RHO;
        SOLARCONST;
        xstup;
        ystup;
    end
    
    methods
        function obj = TemperatureSynthesis()
        end
            
        function Transform(obj)
            obj.dataSeries.setSyntData(obj.dataSeries.getTimevariantNoise());
        end

    end
    
end