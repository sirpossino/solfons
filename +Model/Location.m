classdef Location < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        irradiation;
        temperature;
        windspeed;
        name;
        latitude;
        longitude;
        error;
    end
    
    methods
        function setWeather(obj,l_irradiation,l_temperature,l_windspeed)
            obj.irradiation = l_irradiation;
            obj.temperature = l_temperature;
            obj.windspeed = l_windspeed;
        end
        
        function setName(obj,l_name)
            obj.name = l_name;
            
        end
        
        function setLatitude(obj,l_latitude)
            obj.latitude = l_latitude;
        end
        
        function l_irradiation = getIrradiation(obj)
            l_irradiation = obj.irradiation;
        end
        
        function l_temperature = getTemperature(obj)
            l_temperature = obj.temperature;
        end
        
        function l_windspeed = getWindspeed(obj)
            l_windspeed = obj.windspeed;
        end
        
        
        function setLongitude(obj,l_longitude)
            obj.longitude = l_longitude;
        end
        
        function l_latitude = getLatitude(obj)
            l_latitude = obj.latitude;
        end
        
        function l_longitude = getLongitude(obj)
            l_longitude = obj.longitude;
        end
        
        function setErrorMeasure(obj,l_error)
            obj.error = l_error;
        end
    end
    
end

