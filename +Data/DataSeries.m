classdef DataSeries < Data.Dataset
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected, GetAccess = protected)
        measurement;
        parameters;
        resolution;
        measurementNormal;
        measurementMean;
        measuredWeight;
        weight;
        mean;
        measurementStdDeviation;
        stdDeviation;
        tCompensatedData;
        noise;
        dynamicNoise;
        timevariantNoise;
        syntData;
    end
    
    methods (Abstract)
    end
    
    methods
        function defineMeasurement(obj,l_measurement,l_resolution)
            obj.measurement = l_measurement(:);
            obj.resolution = l_resolution;
        end
        
        function l_measurement = getMeasurement(obj)
            l_measurement = obj.measurement;
        end
        
        function setMeasurementNormal(obj,l_measurementNormal)
            obj.measurementNormal = l_measurementNormal;
        end
        
        function l_measurementNormal=getMeasurementNormal(obj)
            l_measurementNormal=obj.measurementNormal;
        end
        
        function setMeasurementMean(obj,l_mean)
            obj.measurementMean = l_mean(:);
        end
        
        function setMeasurementStdDeviation(obj,l_stdDeviation)
            obj.measurementStdDeviation = l_stdDeviation(:);
        end
            
        function setMeasuredWeight(obj, l_weight)
            obj.measuredWeight = l_weight(:);
        end
            
        function l_weight = getMeasuredWeight(obj)
            l_weight = obj.measuredWeight;
        end
          
        function addParameters(obj, l_parameter)
            try
                obj.parameters = catstruct(obj.parameters,l_parameter);
            catch
                obj.parameters = l_parameter;
            end
        end
        
        function setWeight(obj, l_weight)
            obj.weight = l_weight(:);
        end
        
        function setMean(obj, l_mean)
            obj.mean = l_mean(:);
        end
        
        function setStdDeviation(obj, l_stdDeviation)
            obj.stdDeviation = l_stdDeviation(:);
        end
        
        function l_measurementStdDeviation = getMeasurementStdDeviation(obj)
            l_measurementStdDeviation = obj.measurementStdDeviation;
        end
        
        function l_measurementMean = getMeasurementMean(obj)
            l_measurementMean = obj.measurementMean;
        end
        
        function setTCompensatedData(obj, l_tCompensatedData)
            obj.tCompensatedData = l_tCompensatedData;
        end
        
        function l_tCompensatedData = getTCompensatedData(obj)
            l_tCompensatedData = obj.tCompensatedData;
        end
        
        function setTimeConstant(obj, l_timeConstant)
            obj.parameters.timeConstant = l_timeConstant;
        end
        
        function l_timeConstant = getTimeConstant(obj)
            l_timeConstant = obj.parameters.timeConstant;
        end
            
        function setCorrelation(obj, l_correlation)
            obj.parameters.correlation = l_correlation;
        end
        
        function setNoise(obj, l_noise)
            obj.noise=l_noise;
        end
        
        function setDynamicNoise(obj, l_dynamicNoise)
            obj.dynamicNoise = l_dynamicNoise;
        end
        
        function l_parameter = getParameter(obj)
            l_parameter = obj.parameters;
        end
        
        function l_dynamicNoise = getDynamicNoise(obj)
            l_dynamicNoise = obj.dynamicNoise;
        end
        
        function l_mean = getMean(obj)
            l_mean = obj.mean;
        end
        
        function l_stdDeviation = getStdDeviation(obj)
            l_stdDeviation = obj.stdDeviation;
        end
        
        function setTimevariantNoise(obj,l_timevariantNoise)
            obj.timevariantNoise = l_timevariantNoise;
        end
        
        function l_timevariantNoise = getTimevariantNoise(obj)
            l_timevariantNoise = obj.timevariantNoise;
        end
        
        function setSyntData(obj,l_syntData)
            obj.syntData = l_syntData;
        end
        
        function l_syntData = getSyntData(obj)
            l_syntData = obj.syntData;
        end
        
        function l_noise = getNoise(obj)
            l_noise = obj.noise;
        end
        
    end
end

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
