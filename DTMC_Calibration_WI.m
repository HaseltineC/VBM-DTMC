%    Markov Chain which is time inhomogeneous 
% Voting by Mail DTMC 
%  BASE CASE 
% Extended simulation to 49 days 
clear
clc
% ===============================================================================

%---------  B - A - S - E - L - I - N -E -------------% c118

% ===============================================================================

rr=   0.000162; % v203 % approximation (X65+X66+X67) of 0.0002 rejection rate as starting point
a= 0.0343; % %Includes ballots not returned due to being cancelled by voter, admin, and considered undeliverable v200
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
  %rr=0.003; % rejection rate  
  StatePbase(4,4)= (1-init4)-rr;  % x-percent of the voters will fill out and return ballot within one day
  StatePbase(4,5)= init4;
  StatePbase(4,26)= rr; % X65\X67 voter error non-malicious attack 
  
  
  % V:  Voter returns marked ballot via USPS or drop box 
  % Survey of the Performance of American Elections Dataverse (Caltech/MIT Voting Technology Project) shows 51.5 dropbox, 48.5 USPS
  
  StatePbase(5,6) = 1-M7str; %USPS return
  StatePbase(5,7) = M7str; % Dropbox return
  

  % VI: Marked Ballot in-transit via USPS; From the USPS 2020 audit 93.8% of ballots were processed on time
  %a=0.0001; % the strength of the non-malicious attacks
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
  
  % Final Ballot State Not Counted, Unaltered (1.14%)
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
  
  StatePbase(20,21)=0.485;
  StatePbase(20,22)=0.515;
   
   % VI-A:
  StatePbase(21,22)=1;

  
  % VII-A: 

  % make it a coin flip 50/50
  StatePbase(22,10)=0.5;
  StatePbase(22,12)=0.5;
  
  % Masq: X38-X53: malicious attack, altered ballot
  StatePbase(23,15)=M3str; % mitigation successful 
  StatePbase(23,19)=1-M3str; % attack successful and undetected 
  
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
  
  % X53: Malicious Fake ballot sent 
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
  
  StatePbase35(4,4)= (1-init4e)-rr;  %  20-percent of the voters will fill out and return ballot within one day
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
  StatePbase43(15,14)=0.33; % These numbers are chosen to be fixed (note this limitation in paper)
  StatePbase43(15,16)=0.33;  % in-person absentee now available 
  StatePbase43(15,15)=0.34;
  
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
  StatePt0(5,7)=1;
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
  StatePt0(14,13)=1;
  StatePt0(15,30)=1;
  StatePt0(16,7)=1;
  % modified states  
  %?? Should these states go to NC,A or NC, Lost? < NC, A>
  StatePt0(17,12)=1;
  StatePt0(18,12)=1;
  StatePt0(19,12)=1;
  StatePt0(20,22)=1;
  StatePt0(21,12)=1;
  StatePt0(22,12)=1;
  %Attack states 
  StatePt0(23,13)=1;
  StatePt0(24,13)=1;
  StatePt0(25,13)=1;
  StatePt0(26,11)=1;
  StatePt0(27,11)=1;
  StatePt0(28,13)=1;
  StatePt0(29,13)=1;
  
  
  
  
  
  
  % ======= Step Through ======= %
  
  
  % Simulation from Sept. 17, 2020 to Nov. 6, 2020 (49 days)
  DayReq_Dane_ext=[154468	5951	1946	0	408	3877	2527	2379	2258	1780	16	1238	2154	1912	2069	1831	1580	36	1299	1940	1785	1696	1867	1371	66	74	2479	1494	1729	1654	550	15	40	1293	7827	6589	4946	5763	1888	373	6156	5837	6119	6209	7803	1282	312	77	11	0	0];
  DayReq_Milw_ext=[158347	2328	7908	0	115	12411	4914	6045	4338	2013	1503	87	3292	2224	2375	2086	1135	59	3686	2283	3069	2644	2256	1311	135	1151	2054	4005	2798	2351	738	14	970	1801	10577	9463	8713	9320	3877	2860	8944	8669	9988	9965	11301	4800	4936	19	18	0	0];
  DayReq_Menominee_ext=[0	0	0	0	0	345	1	7	2	3	0	0	5	1	10	1	1	0	0	7	4	3	7	2	0	0	8	10	5	1	8	1	0	3	9	41	4	20	0	19	24	19	19	23	2	1	0	0	0	0	0];
  DayReq_Walworth_ext=[0	0	0	0   15036	316	284	305	256	116	5	33	690	274	227	195	236	7	39	333	287	178	283	173	11	48	382	225	220	175	98	20	19	226	2114	1862	1303	1659	9	45	1399	1277	1433	1689	1993	405	61	20	24	0	0];
  DayReq_WI_ext=[893627	62520	5500	1500	42674	12377	15844	17390	18480	10605	20325	38202	10956	20000	27831	14527	12301	1040	6055	20848	17436	15504	15324	12840	1449	2260	20377	17795	15970	13592	7497	703	1705	11464	83812	72148	62182	63670	12507	5934	64732	61239	63789	65242	80388	11070	7809	5574	1500];
 % County Chosen for the Base Line Modeling 


  
  DayReq=  DayReq_WI_ext;  % choose dane county, milwaukee, or all of WI
  
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
          CU=round(FinalState2(9));
          NCU=round(FinalState2(11));
          CA=round(FinalState2(10));
          NClate=round(FinalState2(8));
          NCLost=round(FinalState2(13));
          NCNoRet=round(FinalState2(30));
          NCA=round(FinalState2(12));
% end
  


% plot the calibration of the model 
  
  WIBallotsReturnedCOUNTED=[132	582	2743	2008	3397	38044	71674	122756	169742	213061	220823	238356	308555	350020	395082	437535	472589	476991	487251	545349	576650	614243	646987	675615	679749	683223	717164	756207	785536	821300	853156	858623	863006	915965	1027585	1130940	1220546	1309782	1333843	1344535	1451462	1545576	1642212	1738638	1853054	1873403	1886533	1924838	1952473];
  WIsim=RecordIntSim(:,9);
  
  days=1:49;
  
  figure(3)
  plot(1:49, WIsim, 'b', 'LineWidth', 1.5, 'MarkerSize', 7);
  hold on
  grid on 
  plot(days,WIBallotsReturnedCOUNTED,'k --','LineWidth', 1.5)
  xlabel('t (Days)','FontSize', 16);
  ylabel('Cummulative # of ballots returned','FontSize', 16);

ax = gca;
ax.YAxis.Exponent = 0;
ax.YAxis.TickLabelFormat = '%.0f';

  %hold off

  