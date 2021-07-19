% For reproducibility of q_table initializatin.
rng(0);

clear;
ttt=clock;
load initial_condition;
ratio = int32(0.1/stepsize);

% key hyperparameters 
num_episode = 100;
discount_factor = 0.8;
learning_rate = 0.1;
max_step = 20000;


action = [J/3 J*2/3 J 1.5*J 3*J];
%q_table = rand(5,25);
q_table = rand(25,5); % changed like this to match

episode_reward_record = zeros(1,num_episode);
global taking_action;
tic;

fprintf("Initial q_table\n"); 
disp(q_table);    

for j=1:num_episode
    
    selected_action = J;
    episode_reward = 0;
    
    for i=1:max_step
        
        PrevContObs = observation;
        
        % take action every 0.1s
        if mod(i,ratio) ==0
            taking_action = true;
            frequency_deviation = observation(1);
            angular_acceleration = observation(2);
            row = q_table_search(frequency_deviation,angular_acceleration);
            [max_q_value_val, max_q_value_val_idx]  = max( q_table(row, :) );
            selected_action = action(max_q_value_val_idx);
            [observation, reward, done] = dynamic_simulation_environment(observation, selected_action);

%             ignore ternimate condition for now
%            if done
%                break;
%            end
%             next observation
            frequency_deviation = observation(1);
            angular_acceleration = observation(2);
            row_next = q_table_search(frequency_deviation,angular_acceleration);
            
            % ADDED FOLLOWING 
            % DISCREPANCY WAS COMING FROM USING "max_q_value_val_idx"
            % instead of "max_q_value_val_idx_next" in the update.
            % USING "max_q_value_val_idx_next" is correct
            [max_q_value_val_next, max_q_value_val_idx_next]  = max( q_table(row_next, :) );
            % ADDED ABOVE
            
            % ADDED HERE FOR COMPARISON!
            
            fprintf("Update formula each component values (disect & compare!)\n");
            fprintf("Observation:"); disp(row);
            fprintf("UpdateActionIndex"); disp(max_q_value_val_idx);
            fprintf("obj.Q_Table(Observation{1}, UpdateActionIndex)"); disp(q_table(row, max_q_value_val_idx));
            fprintf("obj.LearningRate"); disp(learning_rate);
            fprintf("Reward"); disp(reward);
            fprintf("obj.DiscountFactor"); disp(discount_factor);
            fprintf("NextObservation"); disp(row_next);
            fprintf("TargetQValue"); disp(q_table(row_next, max_q_value_val_idx_next));
            fprintf("QTargetEstimate"); disp(reward+discount_factor*q_table(row_next, max_q_value_val_idx_next));
            fprintf("RHS update"); disp(q_table(row, max_q_value_val_idx)+learning_rate*( reward+discount_factor*q_table(row_next, max_q_value_val_idx_next) - q_table(row, max_q_value_val_idx)));
                            
            
            % **Update Rule Corrected : Modified to "max_q_value_val_idx_next" from "max_q_value_val_idx" in q_table(row_next,"max_q_value_val_idx_next)"
            q_table(row, max_q_value_val_idx) = q_table(row, max_q_value_val_idx)+learning_rate*( reward+discount_factor*q_table(row_next, max_q_value_val_idx_next) - q_table(row, max_q_value_val_idx));
            
            
            episode_reward = episode_reward+reward;
            
            fprintf("q_table updated: (row:)"); disp(row);
            disp(q_table);
            
        else
            %normal dynamic simulation        
            taking_action = false;
            [observation, reward, done] = dynamic_simulation_environment(observation, selected_action);           
        end
        
                    
        fprintf("Step:"); disp(i);
        fprintf('PrevContobs:'); disp(PrevContObs);
        fprintf("Action:"); disp(selected_action);
        fprintf("ContObs:"); disp(observation);
        fprintf("Obs:"); disp(q_table_search(observation(1), observation(2)));        
        fprintf("Reward:"); disp(reward);
        fprintf("Done:"); disp(done);
        fprintf("\n");

        
    end
    load initial_condition;
%     episode_reward%show reward
    episode_reward_record(j) = episode_reward;
end
toc;
mean_episode_reward_record = movmean(episode_reward_record,100);
figure
plot(1:num_episode,episode_reward_record,1:num_episode,mean_episode_reward_record)
grid on
xlabel('Episode')
ylabel('Reward')
legend('Episode Reward','Average Reward')
 save q_table q_table;
