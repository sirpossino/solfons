classdef IrradiationAnalysis  < Analysis.Analysis
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RHO;
        SOLARCONST;
        xstup;
        ystup;
    end
    
    methods
        function obj = IrradiationAnalysis(l_RHO)
            obj.RHO = l_RHO;
            obj.SOLARCONST = 1362;%kW/m^2
            obj.xstup = -3.3:0.02:6; %-3.3 to get a unique zero in ystup
            obj.ystup = 1./(exp(exp(-2*obj.xstup)-obj.xstup)+1);
            %obj.xstup = [-10 obj.xstup];
            %obj.ystup = [0 obj.ystup];
            obj.ysensitivity = (obj.ystup(2:end)-obj.ystup(1:end-1))./(obj.xstup(2:end)-obj.xstup(1:end-1));
            obj.xsensitivity = (obj.xstup(2:end)+obj.xstup(1:end-1))*obj.RHO*obj.SOLARCONST/2;
            obj.xsensitivity(1) = obj.xstup(1)*obj.RHO*obj.SOLARCONST;
        end
        
        function backTrafo(obj)
            obj.dataSeries.setMeasurementNormal(interp1(obj.RHO*obj.SOLARCONST*obj.ystup,obj.RHO*obj.SOLARCONST*obj.xstup,obj.dataSeries.getMeasurement));
        end
        

    end
    
end

