% MALICIOUS ATTACK SCENARIOS STUDIED 

% Data Analysis and Scenario Testing

% maximum attack strength -MAS 
% minimum attack strength - minS

MAS=0.10;
minS=0.01;


% DS1: Dane, DS2: Milwaukee, DS3: Menominee, DS4: Walworth (2020 General)
clc;
rng(612452);

  DS1=[154468	5951	1946	0	408	3877	2527	2379	2258	1780	16	1238	2154	1912	2069	1831	1580	36	1299	1940	1785	1696	1867	1371	66	74	2479	1494	1729	1654	550	15	40	1293	7827	6589	4946	5763	1888	373	6156	5837	6119	6209	7803	1282	312	77	11];
  DS2=[158347	2328	7908	0	115	12411	4914	6045	4338	2013	1503	87	3292	2224	2375	2086	1135	59	3686	2283	3069	2644	2256	1311	135	1151	2054	4005	2798	2351	738	14	970	1801	10577	9463	8713	9320	3877	2860	8944	8669	9988	9965	11301	4800	4936	19	18];
  DS3=[0	0	0	0	0	345	1	7	2	3	0	0	5	1	10	1	1	0	0	7	4	3	7	2	0	0	8	10	5	1	8	1	0	3	9	41	4	20	0	19	24	19	19	23	2	1	0	0	0];
  DS4=[0	0	0	0   15036	316	284	305	256	116	5	33	690	274	227	195	236	7	39	333	287	178	283	173	11	48	382	225	220	175	98	20	19	226	2114	1862	1303	1659	9	45	1399	1277	1433	1689	1993	405	61	20	24];
 
DSn=DS2; % County Chosen for the Base Line Modeling 

disp('MILWAUKEE COUNTY DATA'); % list the county working in

% Store data in excel workbook 
 VBMDATA='VBMDTMC_Analysis_MKE_MalAttacks_vtm38.xlsx'; % vtm35 bug fix 

% AUTHOR NOTES: 
% 1- Malicious attack strengths were limited to 0.10 max arc transition
% probability to align more realistic successful attacks 
% 2- Non-malicious attacks are calibrated with the BASELINE 
% 3- There are studies that were not included in the published paper where
% we look at individual mitigations impact on different attacks, remove
% comment brackets and run to view those results 

% number of states 

  % "I"   "II"  "III"   "IV"   "V"   "VI"  "VII"    "NC-Late"  "C-U"    "C-A"    "NC-U"    "NC-A"  "NC-Lost"
  %   1     2       3     4      5     6     7        8           9        10       11        12         13
  
  % Structural Mitigations: M3, M4, M6, M7(inferred through arc)
  
  % "M4"    "M3"    "M6"     "II-A"    "III-A"   "IV-A"  "V-A"   "VI-A"  "VII-A"
  %  14      15      16       17       18          19      20      21      22
  
  % "Masq"    "X14"     "X36"   "X65X67"    "X9"    "X28"    "X53" "NC,NoRet"
  %   23       24        25       26         27      28        29      30

% ===============================================================================

%---------  B - A - S - E - L - I - N -E -------------% v205

% ===============================================================================

rr= 0.00016162; %  v203 % approximation (X65+X66+X67) of 0.0002 rejection rate as starting point
a=  0.0343435; % Includes ballots not returned due to being cancelled by voter, admin, and considered undeliverable v200
M3str = 0.0265;  % low (<20%) for WI in 2020 ... WI has ballot tracking but not automatic notifications % calibrated in v105
M4str = 0.90;  % M4 set to 90% standard as it is favailable but is not a primary mitigation for non-malicious attacks (more M3 dependent) 
M5str= 0.74 ;  % M5 calibrated in validation v204
M6str = 0.4; %  % M6 calibrated in v205
M7str = 0.52; % Survey of the Performance of American Elections Dataverse (Caltech/MIT Voting Technology Project) shows 51.5 dropbox, 48.5 USPS /calibrated v203
init4 = 0.05; % init4 and init4e values change the shape of curve for returned ballots over election period, validated in plotsforVBM
init4e = 0.05+M5str; % init4e represents the usage of M5 



% ===============================================================================

%----------------   x  -  9 ---- Malicious --- Attack -------------------%

%------------------------ ERRANT FAILED SIGNATURE -----------------------%

% ===============================================================================




% ==================   Vary Attack day with all strengths mid ==========
%(1/19 of ballots attacked in the county on a given day in intervals 1 2 3 )

% Initialize an empty array or table to store the results
AX9results = [];

AStrength = MAS-((MAS-minS)/2); % On 7/2024 it was shown that 0.05 arc probability might be too high, 
% In an effort to have less exaggerated results, the attack strengths is now capped 



% Loop through each interval 
for i = [6:33, 36:41, 44:46, 48]
    action=3379;
    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X9(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, i, AStrength);
    
    % Create a row of results for the current interval
    currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, i, AStrength, action];
    
    % Append the current result to the results array or table
    AX9results = [AX9results; currentResult];
end


% % =============     Vary attack strength with attacks in each interval observed 


X9rand=minS:(minS/2):MAS;
num_simulations=length(X9rand);

%M3str1 = 0.150; % will having Ballot Tracks negate the effects of X9

for aday = [10, 20, 25, 30, 40, 45, 48]
    
    for i=1:num_simulations
        if (aday <= 35) && (aday>=5) % int 1 
            action=3413;
        elseif (aday <=43) && (aday>35) % int 2 
            action=3652;
        elseif (aday ==48) % int 4 
            action=31072;
        else
            action=3515;  % int 3 
        end

    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X9(rr, a, init4, init4e, M3str, M4str, M6str, M7str,  DSn, aday, X9rand(i));

        % Create a row of results for the current interval
        currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str,  aday, X9rand(i), action];

        % Append the current result to the results array or table
        AX9results = [AX9results; currentResult];
    end 

end 






sheetname='X9raw';
resultTableX9 = array2table(AX9results, 'VariableNames', {'CU', 'NCU', 'CA', 'NCLate', 'NCLost', 'NCNR', ...
   'NCA', 'rejectionrate','X14X36', 'VoterReturnRateInt1', 'VoterReturnRateInt23', 'M3Strength','M4Strength', 'M6Strength','M7Strength','MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'Scenario'}); 
writetable(resultTableX9, VBMDATA, 'Sheet',sheetname);


% make a new column for not returned ballots that includes lost ballots 
% Create the new column NCNR1 by summing NCLost and NCNR
resultTableX9.NCNR1 = resultTableX9.NCLost + resultTableX9.NCNR;

% create sheet for table to publish
sheetname='Table_X9';
% Define the new order of columns
newColumnOrder = { 'Scenario', 'MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'CU', 'NCU', 'CA', 'NCLate', 'NCNR1', 'NCA'};

% Create a new table with the columns rearranged
ReportingtTableX9 = resultTableX9(:, newColumnOrder);
writetable(ReportingtTableX9, VBMDATA, 'Sheet',sheetname);





% ===============================================================================

%----------------   x  -  29 ---- Malicious --- Attack -------------------%
% malicious attack to ballots intercepted from the EO to voter 
% attack can only occur in intervals 1 and 2 since interval 3 is when
% mail-in ballots are no longer accepted and the only absentee voting
% option is in-person absentee voting M6 
% ===============================================================================

% ==================   Vary Attack day with all strengths mid ==========


% Initialize an empty array or table to store the results
AX29results = [];

AStrength = MAS-((MAS-minS)/2);


% Loop through each interval 
for i = [6:33, 36:41]
    action=4695;
    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X29(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, i, AStrength);
    
    % Create a row of results for the current interval
    currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, i, AStrength, action];
    
    % Append the current result to the results array or table
    AX29results = [AX29results; currentResult];
end


% % =============     Vary attack strength with attacks in each interval observed 


X29rand=minS:(minS/2):MAS;
num_simulations=length(X29rand);



for aday = [15, 20, 25, 30, 40]
    
    for i=1:num_simulations
        if aday <= 35 % interval 1 
            action=7295; 
        elseif aday <= 43 && aday>35 % interval 2
            action=6420;
        else 
            action=0000000;
        end

    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X29(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, aday, X29rand(i));

        % Create a row of results for the current interval
        currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, aday, X29rand(i), action];

        % Append the current result to the results array or table
        AX29results = [AX29results; currentResult];
    end 

end 





sheetname='X29';

resultTableX29 = array2table(AX29results, 'VariableNames', {'CU', 'NCU', 'CA', 'NCLate', 'NCLost', 'NCNR', ...
   'NCA', 'rejectionrate','X14X36', 'VoterReturnRateInt1', 'VoterReturnRateInt23', 'M3Strength','M4Strength', 'M6Strength','M7Strength','MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'Scenario'}); 
writetable(resultTableX29, VBMDATA, 'Sheet',sheetname);

% make a new column for not returned ballots that includes lost ballots 
% Create the new column NCNR1 by summing NCLost and NCNR
resultTableX29.NCNR1 = resultTableX29.NCLost + resultTableX29.NCNR;

sheetname='Table_X29';
% Define the new order of columns
newColumnOrder = { 'Scenario', 'MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'CU', 'NCU', 'CA', 'NCLate', 'NCNR1', 'NCA'};

% Create a new table with the columns rearranged
ReportingtTableX29 = resultTableX29(:, newColumnOrder);
writetable(ReportingtTableX29, VBMDATA, 'Sheet',sheetname);

% ===============================================================================

%----------------   x  -  93 & 94  ---- Malicious --- Attack -------------------%
% malicious attack to ballots mailed from the EO to voter is intercepted by
% an actor who impersonates the voter and returns the ballot erroneously 
% This attack, simialar to X29, can only occur in intervals 1 & 2 when
% ballots are still mailed out 

% ===============================================================================


% ==================   Vary Attack day with all strengths mid ==========


% Initialize an empty array or table to store the results
AX93results = [];

AStrength = MAS-((MAS-minS)/2);


% Loop through each interval 
for i = [6:33, 36:41]
    action=7812;
    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X93X94X95(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, i, AStrength);
    
    % Create a row of results for the current interval
    currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, i, AStrength, action];
    
    % Append the current result to the results array or table
    AX93results = [AX93results; currentResult];
end


% % =============     Vary attack strength with attacks in each interval observed 


X93rand=minS:(minS/2):MAS;
num_simulations=length(X93rand);


for aday = [15, 20, 25, 30, 40]
    
    for i=1:num_simulations
        if aday <= 35 % interval 1 
            action=1123; 
        elseif aday <= 43 && aday>35 % interval 2
            action=2234;
        else % interval 3
            action=1000001;
        end

    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X93X94X95(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, aday, X93rand(i));

        % Create a row of results for the current interval
        currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, aday, X93rand(i), action];

        % Append the current result to the results array or table
        AX93results = [AX93results; currentResult];
    end 

end 






sheetname='X93X94X95';

resultTableX93 = array2table(AX93results, 'VariableNames', {'CU', 'NCU', 'CA', 'NCLate', 'NCLost', 'NCNR', ...
   'NCA', 'rejectionrate','X14X36', 'VoterReturnRateInt1', 'VoterReturnRateInt23', 'M3Strength','M4Strength', 'M6Strength','M7Strength','MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'Scenario'}); 
writetable(resultTableX93, VBMDATA, 'Sheet',sheetname);

% make a new column for not returned ballots that includes lost ballots 
% Create the new column NCNR1 by summing NCLost and NCNR
resultTableX93.NCNR1 = resultTableX93.NCLost + resultTableX93.NCNR;

sheetname='Table_X93X94X95';
% Define the new order of columns
newColumnOrder = { 'Scenario', 'MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'CU', 'NCU', 'CA', 'NCLate', 'NCNR1', 'NCA'};

% Create a new table with the columns rearranged
ReportingtTableX93 = resultTableX93(:, newColumnOrder);
writetable(ReportingtTableX93, VBMDATA, 'Sheet',sheetname);


% ===============================================================================

%----------------   x  -  13 ---- Malicious --- Attack -------------------%
% malicious attack to ballots mailed from the voter to the EO to be counted
% and recorded on election day. This attack mirrors a non-malicious attack
% were ballots can be mistakenly lost in transit via USPS - X14
%
% X13 is the malicious version of X14 
% ===============================================================================
MAS=0.065;
minS=0.001;
% ==================   Vary Attack day with all strengths at 5% ==========

% Initialize an empty array or table to store the results
AX13results = [];

AStrength = MAS-((MAS-minS)/2);


% Loop through each interval 
for i = [6:33, 36:41, 44:46, 48]
    action=9861;
    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X13(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, i, AStrength);
    
    % Create a row of results for the current interval
    currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, i, AStrength, action];
    
    % Append the current result to the results array or table
    AX13results = [AX13results; currentResult];
end


% % =============     Vary attack strength with attacks in each interval observed 


X13rand=minS:(minS/2):MAS;
num_simulations=length(X13rand);


for aday = [10, 20, 25, 30, 40, 45, 48]
    
    for i=1:num_simulations
        if (aday <= 35) && (aday>=5) % int 1 
            action=76412;
        elseif (aday <=43) && (aday>35) % int 2 
            action=12341;
        elseif (aday ==48) % int 4 
            action=735241;
        else
            action=124164;  % int 3 
        end

    [CU, NCU, CA, NCLate, NCLost, NCNR, NCA ] = VBMDTMC_X13(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, aday, X13rand(i));

        % Create a row of results for the current interval
        currentResult = [CU, NCU, CA, NCLate, NCLost, NCNR, NCA, rr, a, init4, init4e, M3str, M4str, M6str, M7str, aday, X13rand(i), action];

        % Append the current result to the results array or table
        AX13results = [AX13results; currentResult];
    end 

end 





sheetname='X13';

resultTableX13 = array2table(AX13results, 'VariableNames', {'CU', 'NCU', 'CA', 'NCLate', 'NCLost', 'NCNR', ...
   'NCA', 'rejectionrate','X14X36', 'VoterReturnRateInt1', 'VoterReturnRateInt23', 'M3Strength','M4Strength', 'M6Strength','M7Strength','MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'Scenario'}); 
writetable(resultTableX13, VBMDATA, 'Sheet',sheetname);

% make a new column for not returned ballots that includes lost ballots 
% Create the new column NCNR1 by summing NCLost and NCNR
resultTableX13.NCNR1 = resultTableX13.NCLost + resultTableX13.NCNR;

sheetname='Table_X13';
% Define the new order of columns
newColumnOrder = { 'Scenario', 'MaliciousAttackDAY', 'MaliciousAttackSTRENGTH', 'CU', 'NCU', 'CA', 'NCLate', 'NCNR1', 'NCA'};

% Create a new table with the columns rearranged
ReportingtTableX13 = resultTableX13(:, newColumnOrder);
writetable(ReportingtTableX13, VBMDATA, 'Sheet',sheetname);



disp('Analysis Complete')
