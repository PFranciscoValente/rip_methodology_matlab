%------------------------------------------------------------------------
% Filt to stratify the ocurrance of events, stratifying the days
% into the 4 periods (14 days, 30 days, 6 months and 1 year)
%------------------------------------------------------------------------

function label = stratify_events(events_ocurrence,events_days)

    label = zeros(length(events_days),4);
    
    % 1st column : events in 14 days
    % 2nd column : events in 30 days
    % 3rd column : events in 6 months (180 days -> 30*6)
    % 4th column : events in 1 year (365 days)

    % POSITIVE SAMPLES > OCCURANCE OF THE EVENTS

    idx_14days = find(events_days<=14 & events_ocurrence==1);
    idx_30days = find(events_days<=30 & events_ocurrence==1);
    idx_6months = find(events_days<=180 & events_ocurrence==1);
    idx_1year = find(events_days<365 & events_ocurrence==1);

    label(idx_14days,1) = 1;
    label(idx_30days,2) = 1;
    label(idx_6months,3) = 1;
    label(idx_1year,4) = 1;
    
    % NULL SAMPLES (without time of follow-up)
    % e.g: if time of f-up is 220 and the patient survived, so the f-up column 
    % of 1 year instead of a 0 value, it will have a NaN
    
    idx_14days = find(events_days<=14 & events_ocurrence==0);
    idx_30days = find(events_days<=30 & events_ocurrence==0);
    idx_6months = find(events_days<=180 & events_ocurrence==0);
    idx_1year = find(events_days<365 & events_ocurrence==0);

    label(idx_14days,1) = NaN;
    label(idx_30days,2) = NaN;
    label(idx_6months,3) = NaN;
    label(idx_1year,4) = NaN;
    
end