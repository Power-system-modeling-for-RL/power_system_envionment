clear
clc


load wtf_cct_result_basecase1.mat cct_result

cct_basecase = cct_result;

load wtf_cct_results_basecase0.mat cct_result

resolution = length(cct_result(1,:));

resolution = 400;

location_record = randi([1,8], resolution, resolution);
type_record = randi([1,5], resolution, resolution);

clear_time_mean = 1/60*12;
clear_time_std = 1/60*6;


clear_time_pool = abs(normrnd(clear_time_mean,clear_time_std,[resolution,resolution]));

basin_right = zeros(resolution);

for i = 1:resolution
    for j = 1:resolution
        
       
           
        if  location_record(i,j) == 3 && clear_time_pool(i,j) < 0.48
       % if  location_record(i,j) == 3 && clear_time_pool(i,j) < 0.48
        % if   location_record(i,j) == 3 && clear_time_pool(i,j) < 0.82
            
            basin_right(i,j) = 1;
            
        elseif location_record(i,j) == 4 && clear_time_pool(i,j) < 100
            
            basin_right(i,j) = 1;
            
        elseif location_record(i,j) == 5 && clear_time_pool(i,j) < 0.37
       % elseif location_record(i,j) == 5 && clear_time_pool(i,j) < 0.44
       % elseif location_record(i,j) == 5 && clear_time_pool(i,j) < 0.36
            
             basin_right(i,j) = 1;
            
         elseif location_record(i,j) == 6 && clear_time_pool(i,j) < 100
      %  elseif location_record(i,j) == 6 
      %  elseif location_record(i,j) == 6   
            basin_right(i,j) = 1;
            
        end
        
        
        
    end
end

basin_num_right = sum(sum(basin_right(:,:),1),2)/(resolution^2);


