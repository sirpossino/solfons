classdef ModelSet < handle
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        location;
    end
    
    methods
        function obj = ModelSet()
            obj.location=Model.Location.empty();
        end
        
        function addLocation(obj,l_location)
            obj.location(end+1) = l_location;
        end
        
        function l_location = getLocation(obj,id)
            l_location = obj.location(id);
        end
        
    end
    
end

