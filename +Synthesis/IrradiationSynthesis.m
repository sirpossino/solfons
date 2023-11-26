classdef IrradiationSynthesis  < Synthesis.Synthesis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RHO;
        SOLARCONST;
        xstup;
        ystup;
    end
    
    methods
        function obj = IrradiationSynthesis(l_RHO)
            obj.RHO = l_RHO;
            obj.SOLARCONST = 1362;%kW/m^2
            obj.xstup = -3.3:0.02:6; %-3.3 to get a unique zero in ystup
            obj.xstup(1) = -10;
            obj.xstup(end) = 12;
            obj.ystup = 1./(exp(exp(-2*obj.xstup)-obj.xstup)+1);
        end
            
        function Transform(obj)
            if(isnan(interp1(obj.RHO*obj.SOLARCONST*obj.xstup,obj.RHO*obj.SOLARCONST*obj.ystup,obj.dataSeries.getTimevariantNoise())))
                error('unfortunately, sth. got nan');
            end
            obj.dataSeries.setSyntData(interp1(obj.RHO*obj.SOLARCONST*obj.xstup,obj.RHO*obj.SOLARCONST*obj.ystup,obj.dataSeries.getTimevariantNoise()));
        end

    end
    
end

