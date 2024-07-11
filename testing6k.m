clear clc 
hold off






%    Markov Chain which is time inhomogeneous 
% Voting by Mail DTMC 
%  BASE CASE 
% Extended simulation to 51 days 

% DS1: Dane, DS2: Milwaukee, DS3: Menominee, DS4: Walworth (2020 General)
clc;
rng(612452);

  DS1=[154468	5951	1946	0	408	3877	2527	2379	2258	1780	16	1238	2154	1912	2069	1831	1580	36	1299	1940	1785	1696	1867	1371	66	74	2479	1494	1729	1654	550	15	40	1293	7827	6589	4946	5763	1888	373	6156	5837	6119	6209	7803	1282	312	77	11	0	0];
  DS2=[158347	2328	7908	0	115	12411	4914	6045	4338	2013	1503	87	3292	2224	2375	2086	1135	59	3686	2283	3069	2644	2256	1311	135	1151	2054	4005	2798	2351	738	14	970	1801	10577	9463	8713	9320	3877	2860	8944	8669	9988	9965	11301	4800	4936	19	18	];
  DS3=[0	0	0	0	0	345	1	7	2	3	0	0	5	1	10	1	1	0	0	7	4	3	7	2	0	0	8	10	5	1	8	1	0	3	9	41	4	20	0	19	24	19	19	23	2	1	0	0	0	0	0];
  DS4=[0	0	0	0   15036	316	284	305	256	116	5	33	690	274	227	195	236	7	39	333	287	178	283	173	11	48	382	225	220	175	98	20	19	226	2114	1862	1303	1659	9	45	1399	1277	1433	1689	1993	405	61	20	24	0	0];
 
DSn=DS2; % County Chosen for the Base Line Modeling 

disp('MILWAUKEE COUNTY DATA'); % list the county working in




 

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


% number of states 

  % "I"   "II"  "III"   "IV"   "V"   "VI"  "VII"    "NC-Late"  "C-U"    "C-A"    "NC-U"    "NC-A"  "NC-Lost"
  %   1     2       3     4      5     6     7        8           9        10       11        12         13
  
  % Structural Mitigations: M3, M4, M6, M7(inferred through arc)
  
  % "M4"    "M3"    "M6"     "II-A"    "III-A"   "IV-A"  "V-A"   "VI-A"  "VII-A"
  %  14      15      16       17       18          19      20      21      22
  
  % "Masq"    "X14"     "X36"   "X65X67"    "X9"    "X28"    "X53" "NC,NoRet"
  %   23       24        25       26         27      28        29      30
  
  n=30; 
  
  %------------- Pbase -----------------------%
  % First we model the state transition matrix for the base condition of
  % all mitigations available and only non-malicious attacks are active 
  
  StatePbase = zeros(n,n);
  
  % I: Voter Requests ballot from election office
  
  StatePbase(1,2)=1;
  
  
  % II: Unmarked Ballot sent from Election Office
  
  StatePbase(2,3)=1;

  
  
  %  III: Unmarked Ballot in-transit via USPS 
  %       USPS performance 93.8% on-time from Inspector General of USPS
  
  StatePbase(3,4)=0.938;
  StatePbase(3,3)=0.062;
  

  %  IV: Voter marks ballot

  StatePbase(4,4)= 1-(init4+rr);  % x-percent of the voters will fill out and return ballot within one day
  StatePbase(4,5)= init4;   % percentage of voters who return their ballots within one day
  StatePbase(4,26)= rr; % X65\X67 voter error non-malicious attack 
 
  
  % V:  Voter returns marked ballot via USPS or drop box 
  % Survey of the Performance of American Elections Dataverse (Caltech/MIT Voting Technology Project) shows 51.5 dropbox, 48.5 USPS
  
  StatePbase(5,6) = 1-M7str; %USPS return
  StatePbase(5,7) = M7str; % Dropbox return
  

  % VI: Marked Ballot in-transit via USPS; From the USPS 2020 audit 93.8% of ballots were processed on time
 % a=0.0001; % the strength of the non-malicious loss of ballot attacks 
  StatePbase(6,7)=0.938;
  StatePbase(6,24)= a; % X14 low prob. non-malious attack 
  StatePbase(6,6)= 0.062-a;
  
  
  % VII: Marked ballot processed at election office for verification prior to election day tabulation 
  
  StatePbase(7,9)= 1-a;
  StatePbase(7,25)=a; % X36 low prob. non-malious attack 
  
  % Final Ballot State Not Counted, LATE
  StatePbase(8,8)=1;
  
  % Final Ballot State  Counted, Unaltered 
  StatePbase(9,9)=1;
  
  % Final Ballot State Counted, Altered
  StatePbase(10,10)=1;
  
  % Final Ballot State Not Counted, Unaltered
  StatePbase(11,11)=1;
  
  % Final Ballot State Not Counted, Altered 
  StatePbase(12,12)=1;
  
  % Final Ballot State Not Counted, Lost 
  StatePbase(13,13)=1;
  
  % M4: Request replacement ballot
  StatePbase(14,2)=1;
  
  % M3: Ballot Status Notifications sent to voter
  StatePbase(15,14)=0.5; % These numbers are chosen to be fixed (note this limitation in paper)
  StatePbase(15,16)=0;  % in-person absentee not available until day 35 
  StatePbase(15,15)=0.5;
  
  % M6: Voter decides In-Person absentee voting
  StatePbase(16,7)=1;
  
  % II-A
  StatePbase(17,18)=1;
  
  % III-A
  StatePbase(18,19)=0.9;
  StatePbase(18,18)=0.1;
  
  % IV-A: 
  StatePbase(19,19)=0.3; % 30% will return ballots on the same day
  StatePbase(19,20)=0.7;
  
  % V-A: 
  
  StatePbase(20,21)=1-M7str;
  StatePbase(20,22)=M7str;
   
   % VI-A:
  StatePbase(21,22)=1;

  
   % VII-A: 
  % make it a coin flip 50/50
  StatePbase(22,10)=0.5;
  StatePbase(22,12)=0.5;
  
  % Masq: X29: malicious attack, altered ballot
  StatePbase(23,14)=M3str; % mitigation successful 
  StatePbase(23,17)=1-M3str; % attack successful and undetected 
  
  % X14: non-malicious lost ballot USPS
  StatePbase(24,15)= M3str;
  StatePbase(24,13)= 1-M3str;
  
  %X36: non-malicious ballot lost in election room 
  %          ?? this should not have a mitigation if lost at election office 
  %          correct, no mitigation for this 
  StatePbase(25,13)= 1;
  
  % X65/X67: non-malious voter error in signature 
  % can be mitigated by M3
  % ballot trax does check (news articles to confirm) 
  StatePbase(26,11)= 1-M3str;
  StatePbase(26,15)= M3str;
  
  % X9: Malicious challenge of ballot signature 
  StatePbase(27,15)= M3str;
  StatePbase(27,11)= 1-M3str;
  
  % X28: Malicious incomplete ballot (fail to stuff) 
  StatePbase(28,14)= M4str;
  StatePbase(28,18)= 1-M4str;
  
  % X939495: Malicious ballot intercept 
  StatePbase(29,14)= M4str;
  StatePbase(29,17)= 1-M4str;
  
  % Final Ballot State Not Counted, Not Returned 
  StatePbase(30,30)=1; 
  
  %------------- Pbase35 -----------------------%
  % First we model the state transition matrix for the base condition of
  % all mitigations available and only non-malicious attacks are active
  % this section is to reflect that the new requests for a ballot rmalicious ecieved
  % after in-person absentee is opened 
  
  StatePbase35 = StatePbase;
  
  % II: Unmarked Ballot sent from Election Office to in-person absentee 
  StatePbase35(2,3)=1-M6str;
  StatePbase35(2,16)=M6str;
  
    %  IV: Voter marks ballot
  
  StatePbase35(4,4)= 1-(init4e+rr);  %  20-percent of the voters will fill out and return ballot within one day
  StatePbase35(4,5)= init4e;
  StatePbase35(4,26)= rr; % X65\X67 voter error non-malicious attack 
  
  
    % M3: Ballot Status Notifications sent to voter
  StatePbase35(15,14)=0.33; % These numbers are chosen to be fixed (note this limitation in paper)
  StatePbase35(15,16)=0.33;  % in-person absentee now available 
  StatePbase35(15,15)=0.34; 
  
  
    %------------- Pbase43 -----------------------%
  % First we model the state transition matrix for the base condition of
  % all mitigations available and only non-malicious attacks are active
  % this section is to reflect that the new requests for a ballot recieved
  % after in-person absentee is opened and in-person absentee no longer mailed  
  
  StatePbase43 = StatePbase35;
  
  % II: Unmarked Ballot sent from Election Office to in-person absentee 
  StatePbase43(2,3)=0;
  StatePbase43(2,16)=1;
  
    % M3: Ballot Status Notifications sent to voter
  StatePbase43(15,14)=0; % These numbers are chosen to be fixed (note this limitation in paper)
  StatePbase43(15,16)=0.5;  % in-person absentee now available 
  StatePbase43(15,15)=0.5;  %  mailed ballot requests no longer accepted 
  
%---------------- Pt0 ------------------------------%

  % Next we model the state transition matrix for the t=0 condition of
  % election deadline passing  
  
  StatePt0 = zeros(n,n);
  
  % Not Counted LATE 
  
  StatePt0(1,30)=1;  
  StatePt0(2,30)=1;
  StatePt0(3,30)=1;
  StatePt0(4,30)=1;
  % Counted 
  StatePt0(5,7)= M7str;
  StatePt0(5,8)=1 - M7str;
  StatePt0(6,8)=1; % not counted late if at post office at t=0
  StatePt0(7,9)=1;
  % Final states
  StatePt0(8,8)=1;
  StatePt0(9,9)=1;
  StatePt0(10,10)=1;
  StatePt0(11,11)=1;
  StatePt0(12,12)=1;
  StatePt0(13,13)=1;
  StatePt0(30,30)=1;
  % mitigations
  StatePt0(14,30)=1;
  StatePt0(15,30)=1;
  StatePt0(16,7)=1;
  % modified states  
  %?? Should these states go to NC,A or NC, Lost? < NC, A>
  StatePt0(17,12)=1;
  StatePt0(18,12)=1;
  StatePt0(19,12)=1;
  StatePt0(20,22)=1;
  StatePt0(21,12)=1;
  StatePt0(22,10)=0.5; % 50/50 chance of altered ballot getting through processing 
  StatePt0(22,12)=0.5;
  %Attack states 
  StatePt0(23,12)=1;
  StatePt0(24,13)=1;
  StatePt0(25,13)=1;
  StatePt0(26,11)=1;
  StatePt0(27,11)=1;
  StatePt0(28,13)=1;
  StatePt0(29,12)=1;
  
    % ERROR CHECKING STOCHASTIC PROPERTY check row and column of matricies 
  
 
checkcolumnrow(StatePbase, 1);
checkcolumnrow(StatePbase35, 2);
checkcolumnrow(StatePbase43, 3);
checkcolumnrow(StatePt0, 4);

  
  
  
  
  
  % ======= Step Through ======= %
  

  
  DayReq=DSn;  % choose dane county, milwaukee, or all of WI
  
  StateInit= zeros(1,n);
  StateInit(1,1)=DayReq(1,1);
  
  FinalState2=StateInit*StatePbase;
  RecordIntSim=zeros(49,n);
  
  % interval 1 
  
  for i=1:34 % normal conditions before in-person absentee is available (no M6)
      
      StateInit(1,1)=DayReq(1,i);
      FinalState2=StateInit*StatePbase;
      StateInit=FinalState2;
      RecordIntSim(i,:)= FinalState2;
          
  end
  
  % interval 2 

  for i=35:42 % normal conditions with in-person absentee 
      
      StateInit(1,1)=DayReq(1,i);
      FinalState2=StateInit*StatePbase35;
      StateInit=FinalState2;
      RecordIntSim(i,:)= FinalState2;
          
  end 
  
  %interval 3 

   for i=43:47 % normal conditions with in-person absentee 
      
      StateInit(1,1)=DayReq(1,i);
      FinalState2=StateInit*StatePbase43;
      StateInit=FinalState2;
      RecordIntSim(i,:)= FinalState2;
          
   end 

  % interval 4 
  
    for i=48:49 % election day and the days after 
      
      StateInit(1,1)=DayReq(1,i);
      FinalState2=StateInit*StatePt0;
      StateInit=FinalState2;
      RecordIntSim(i,:)= FinalState2;
          
    end
    

    
    

          % GOF test KS-Test 2 independent functions of all returned
          % ballots 
          
          CountyRet=RecordIntSim(:,9)+RecordIntSim(:,11)+RecordIntSim(:,10)+RecordIntSim(:,12);
          milwRealWorld = [ 11 11 45 2145 5678 10831 15034 20006 24039 27037 35090 44216 53637 63000 70734 72880 74440 84794 89209 96823 101581 106167 107781 109184 114679 122053 126777 132701 138382 139868 141069 148998 164360 179833 193998 206452 214636 219189 235695 250473 265685 282440 299610 307251 314011 319734 325547 325574 325587];

          [h,p]=kstest2(milwRealWorld,CountyRet);
          if h==1 && (p>=0.05)% reject  null hypothesis that two sets are from same distribution
               CU=0;
              NCU=0;
              CA=0;
              NClate=0;
              NCLost=0;
              NCNoRet=0;
              NCA=0;
          
          else  % fail to reject null hypothesis ( distributions of real world and model are similar) 
          CU=round(FinalState2(9));
          NCU=round(FinalState2(11));
          CA=round(FinalState2(10));
          NClate=round(FinalState2(8));
          NCLost=round(FinalState2(13));
          NCNoRet=round(FinalState2(30));
          NCA=round(FinalState2(12));
          
          end 

  format short 


% Define milwSIM and milwRealWorld data
milwSIM = RecordIntSim(:, 9)+RecordIntSim(:, 11);
MKE=[0	0	11	11	45	2145	5678	10831	15034	20006	24039	27037	35090	44216	53637	63000	70734	72880	74440	84794	89209	96823	101581	106167	107781	109184	114679	122053	126777	132701	138382	139868	141069	148998	164360	179833	193998	206452	214636	219189	235695	250473	265685	282440	299610	307251	314011	319734	325547];
figure(1)
% Create a plot for milwSIM
plot(1:49, milwSIM, 'k--', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on

% Create a plot for milwRealWorld
plot(1:49, MKE, 'b', 'LineWidth', 1.5, 'MarkerSize', 7);

% Change Y-axis tick format to whole numbers with commas
ytickformat('%.1f ballots');

% Add labels and adjust font size
xlabel('t (Days)', 'FontSize', 14);
ylabel('Cumulative # of returned ballots', 'FontSize', 14);
title('Comparison of VBM-DTMC model and Milwaukee County Data', 'FontSize', 16);

% Add a legend to distinguish the two data sets
legend('DTMC model', 'MKE recorded ballots returned');

% Optionally, you can add grid lines if desired
grid on;


% ========================================================================+%
%
%                Model malicious attack active for X13
%
% ========================================================================+%


%------- ATTACK DAY -------% 
AttackDay=43;
%----- ATTACK STRENGTH ----%
AStrength=0.000000001;

% refresh baseline input values 
rr= 0.00016162; %  v203 % approximation (X65+X66+X67) of 0.0002 rejection rate as starting point
a=  0.0343435; % Includes ballots not returned due to being cancelled by voter, admin, and considered undeliverable v200
M3str = 0.0265;  % low (<20%) for WI in 2020 ... WI has ballot tracking but not automatic notifications % calibrated in v105
M4str = 0.990;  % M4 set to 90% standard as it is favailable but is not a primary mitigation for non-malicious attacks (more M3 dependent) 
M5str= 0.74 ;  % M5 calibrated in validation v204
M6str = 0.4; %  % M6 calibrated in v205
M7str = 0.52; % Survey of the Performance of American Elections Dataverse (Caltech/MIT Voting Technology Project) shows 51.5 dropbox, 48.5 USPS /calibrated v203
init4 = 0.05; % init4 and init4e values change the shape of curve for returned ballots over election period, validated in plotsforVBM
init4e = 0.05+M5str; % init4e represents the usage of M5 



%function [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = VBMDTMC_X13(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, AttackDay, AStrength)
    % Define the number of states
    n = 30;
    
    % Initialize state transition matrices for various conditions
    StatePbase = initializeStatePbase(n, init4, rr, a, M3str, M4str, M7str);
    StatePbase35 = adjustForInPersonAbsentee(StatePbase, M6str, init4e, rr);
    StatePbase43 = adjustNoLateBallotMail(StatePbase35);
    StatePt0 = initializeStatePt0(n, M7str);
    StatePMalAttack = applyMaliciousAttack(StatePbase, AStrength);
    StatePMalAttack35 = applyMaliciousAttack(StatePbase35, AStrength);
    StatePMalAttack43 = applyMaliciousAttack(StatePbase43, AStrength);
    StatePMalAttackPt0 = applyMaliciousAttack(StatePt0, AStrength);

    % Simulate the election cycle
    [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = modelElectionCycle(DS2, AttackDay, ...
        StatePbase, StatePbase35, StatePbase43, StatePt0, ...
        StatePMalAttack, StatePMalAttack35, StatePMalAttack43, StatePMalAttackPt0);
%end

%clear;

function StatePbase = initializeStatePbase(n, init4, rr, a, M3str, M4str, M7str)
    StatePbase = zeros(n, n);
    StatePbase(1, 2) = 1;
    StatePbase(2, 3) = 1;
    StatePbase(3, 4) = 0.938;
    StatePbase(3, 3) = 0.062;
    StatePbase(4, 4) = 1 - (init4 + rr);
    StatePbase(4, 5) = init4;
    StatePbase(4, 26) = rr;
    StatePbase(5, 6) = 1 - M7str;
    StatePbase(5, 7) = M7str;
    StatePbase(6, 7) = 0.938;
    StatePbase(6, 24) = a;
    StatePbase(6, 6) = 0.062 - a;
    StatePbase(7, 9) = 1 - a;
    StatePbase(7, 25) = a;
    StatePbase(8, 8) = 1;
    StatePbase(9, 9) = 1;
    StatePbase(10, 10) = 1;
    StatePbase(11, 11) = 1;
    StatePbase(12, 12) = 1;
    StatePbase(13, 13) = 1;
    StatePbase(14, 2) = 1;
    StatePbase(15, 14) = 0.5;
    StatePbase(15, 15) = 0.5;
    StatePbase(16, 7) = 1;
    StatePbase(17, 18) = 1;
    StatePbase(18, 19) = 0.9;
    StatePbase(18, 18) = 0.1;
    StatePbase(19, 19) = 0.3;
    StatePbase(19, 20) = 0.7;
    StatePbase(20, 21) = 1 - M7str;
    StatePbase(20, 22) = M7str;
    StatePbase(21, 22) = 1;
    StatePbase(22, 10) = 0.5;
    StatePbase(22, 12) = 0.5;
    StatePbase(23, 14) = M3str;
    StatePbase(23, 17) = 1 - M3str;
    StatePbase(24, 15) = M3str;
    StatePbase(24, 13) = 1 - M3str;
    StatePbase(25, 13) = 1;
    StatePbase(26, 11) = 1 - M3str;
    StatePbase(26, 15) = M3str;
    StatePbase(27, 15) = M3str;
    StatePbase(27, 11) = 1 - M3str;
    StatePbase(28, 14) = M4str;
    StatePbase(28, 18) = 1 - M4str;
    StatePbase(29, 14) = M4str;
    StatePbase(29, 17) = 1 - M4str;
    StatePbase(30, 30) = 1;
end

function StatePbase35 = adjustForInPersonAbsentee(StatePbase, M6str, init4e, rr) % init4e == M5str
    StatePbase35 = StatePbase;
    StatePbase35(2, 3) = 1 - M6str;
    StatePbase35(2, 16) = M6str;
    StatePbase35(4, 4) = 1 - (init4e + rr);
    StatePbase35(4, 5) = init4e;
    StatePbase35(4, 26) = rr;
    StatePbase35(15, 14) = 0.33;
    StatePbase35(15, 16) = 0.33;
    StatePbase35(15, 15) = 0.34;
end

function StatePbase43 = adjustNoLateBallotMail(StatePbase)
    StatePbase43 = StatePbase;
    StatePbase43(2, 3) = 0;
    StatePbase43(2, 16) = 1;
    StatePbase43(15, 14) = 0.0;
    StatePbase43(15, 16) = 0.5;
    StatePbase43(15, 15) = 0.5;
end

function StatePt0 = initializeStatePt0(n, M7str)
    StatePt0 = zeros(n, n);
    StatePt0(1, 30) = 1;
    StatePt0(2, 30) = 1;
    StatePt0(3, 30) = 1;
    StatePt0(4, 30) = 1;
    StatePt0(5, 7) = M7str;
    StatePt0(5, 8) = 1 - M7str;
    StatePt0(6, 8) = 1;
    StatePt0(7, 9) = 1;
    StatePt0(8, 8) = 1;
    StatePt0(9, 9) = 1;
    StatePt0(10, 10) = 1;
    StatePt0(11, 11) = 1;
    StatePt0(12, 12) = 1;
    StatePt0(13, 13) = 1;
    StatePt0(30, 30) = 1;
    StatePt0(14, 30) = 1;
    StatePt0(15, 30) = 1;
    StatePt0(16, 7) = 1;
    StatePt0(17, 12) = 1;
    StatePt0(18, 12) = 1;
    StatePt0(19, 12) = 1;
    StatePt0(20, 22) = 1;
    StatePt0(21, 12) = 1;
    StatePt0(22, 10) = 0.5;
    StatePt0(22, 12) = 0.5;
    StatePt0(23, 12) = 1;
    StatePt0(24, 13) = 1;
    StatePt0(25, 13) = 1;
    StatePt0(26, 11) = 1;
    StatePt0(27, 11) = 1;
    StatePt0(28, 13) = 1;
    StatePt0(29, 13) = 1;
end

function StatePMalAttack = applyMaliciousAttack(StatePbase, AStrength)
    StatePMalAttack = StatePbase;
    StatePMalAttack(6, 7) = StatePbase(6,7) - (AStrength);
    StatePMalAttack(6, 6) = StatePbase(6,6);
    StatePMalAttack(6, 24) = AStrength;
end

function [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = modelElectionCycle(DSn, AttackDay, ...
    StatePbase, StatePbase35, StatePbase43, StatePt0, ...
    StatePMalAttack, StatePMalAttack35, StatePMalAttack43, StatePMalAttackPt0)

    DayReq = DSn;
    n = size(StatePbase, 1);
    StateInit = zeros(1, n);
    StateInit(1, 1) = DayReq(1, 1);
    FinalState2 = StateInit * StatePbase;
    RecordIntSim = zeros(49, n);

    intervals = {1:34, 35:42, 43:47, 48:49};
    StatePbaseIntervals = {StatePbase, StatePbase35, StatePbase43, StatePt0};
    StatePMalAttackIntervals = {StatePMalAttack, StatePMalAttack35, StatePMalAttack43, StatePMalAttackPt0};

    for interval = 1:length(intervals)
        if AttackDay >= intervals{interval}(1) && AttackDay <= intervals{interval}(end)
            for i = intervals{interval}(1):(AttackDay-1)
                StateInit(1, 1) = DayReq(1, i);
                FinalState2 = StateInit * StatePbaseIntervals{interval};
                StateInit = FinalState2;
                RecordIntSim(i, :) = FinalState2;
            end

            StateInit(1, 1) = DayReq(1, AttackDay);
            FinalState2 = StateInit * StatePMalAttackIntervals{interval};
            StateInit = FinalState2;
            RecordIntSim(AttackDay, :) = FinalState2;

            for i = (AttackDay+1):intervals{interval}(end)
                StateInit(1, 1) = DayReq(1, i);
                FinalState2 = StateInit * StatePbaseIntervals{interval};
                StateInit = FinalState2;
                RecordIntSim(i, :) = FinalState2;
            end
        else
            for i = intervals{interval}
                StateInit(1, 1) = DayReq(1, i);
                FinalState2 = StateInit * StatePbaseIntervals{interval};
                StateInit = FinalState2;
                RecordIntSim(i, :) = FinalState2;
            end
        end
    end

    CU = round(FinalState2(9));
    NCU = round(FinalState2(11));
    CA = round(FinalState2(10));
    NClate = round(FinalState2(8));
    NCLost = round(FinalState2(13));
    NCNoRet = round(FinalState2(30));
    NCA = round(FinalState2(12));
    
    % Define milwSIM and milwRealWorld data
milwSIMX13 = RecordIntSim(:, 9)+RecordIntSim(:, 11);
MKE=[0	0	11	11	45	2145	5678	10831	15034	20006	24039	27037	35090	44216	53637	63000	70734	72880	74440	84794	89209	96823	101581	106167	107781	109184	114679	122053	126777	132701	138382	139868	141069	148998	164360	179833	193998	206452	214636	219189	235695	250473	265685	282440	299610	307251	314011	319734	325547];
figure(3)
% Create a plot for milwSIM
plot(1:49, milwSIMX13, 'r--', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on

% Create a plot for milwRealWorld
plot(1:49, MKE, 'b', 'LineWidth', 1.5, 'MarkerSize', 7);

% Change Y-axis tick format to whole numbers with commas
ytickformat('%.1f ballots');

% Add labels and adjust font size
xlabel('t (Days)', 'FontSize', 14);
ylabel('Cumulative # of returned ballots', 'FontSize', 14);
title('Comparison of VBM-DTMC model with X-13 and Milwaukee County Data', 'FontSize', 16);

% Add a legend to distinguish the two data sets
legend('DTMC model', 'MKE recorded ballots returned');

% Optionally, you can add grid lines if desired
grid on;

end






