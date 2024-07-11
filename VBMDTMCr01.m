function[CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = VBMDTMCr01(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn)
    % number of states 
    n = 30; 

    % Initialize base state transition matrix
    StatePbase = initializeStatePbase(n, rr, a, init4, M7str, M3str, M4str);
    StatePbase35 = initializeStatePbase35(StatePbase, M6str, init4e, rr);
    StatePbase43 = initializeStatePbase43(StatePbase35);
    StatePt0 = initializeStatePt0(n, M7str);

    % Check Stochastic Properties
    checkStochasticProperties({StatePbase, StatePbase35, StatePbase43, StatePt0});

    % Simulation
    DayReq = DSn;
    StateInit = zeros(1, n);
    StateInit(1, 1) = DayReq(1, 1);
    RecordIntSim = runSimulation(DayReq, StatePbase, StatePbase35, StatePbase43, StatePt0, StateInit, n);

    % GOF test KS-Test
    [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = goodnessOfFitTest(RecordIntSim, n);
end

function StatePbase = initializeStatePbase(n, rr, a, init4, M7str, M3str, M4str)
    % Define and return the base state transition matrix
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
    StatePbase(15, 16) = 0;  
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

function StatePbase35 = initializeStatePbase35(StatePbase, M6str, init4e, rr)
    % Modify and return the state transition matrix for in-person absentee voting
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

function StatePbase43 = initializeStatePbase43(StatePbase35)
    % Modify and return the state transition matrix for post in-person absentee voting
    StatePbase43 = StatePbase35;
    StatePbase43(2, 3) = 0;
    StatePbase43(2, 16) = 1;
    StatePbase43(15, 14) = 0; 
    StatePbase43(15, 16) = 0.5;  
    StatePbase43(15, 15) = 0.5;
end

function StatePt0 = initializeStatePt0(n, M7str)
    % Define and return the state transition matrix for the election deadline
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
    StatePt0(29, 12) = 1;
end

function checkStochasticProperties(matrices)
    % Check stochastic properties of matrices
    for i = 1:length(matrices)
        checkcolumnrow(matrices{i}, i);
    end
end

function RecordIntSim = runSimulation(DayReq, StatePbase, StatePbase35, StatePbase43, StatePt0, StateInit, n)
    % Run simulation over 49 days
    RecordIntSim = zeros(49, n);

    % Interval 1
    for i = 1:34
        StateInit(1, 1) = DayReq(1, i);
        FinalState2 = StateInit * StatePbase;
        StateInit = FinalState2;
        RecordIntSim(i, :) = FinalState2;
    end

    % Interval 2 
    for i = 35:42
        StateInit(1, 1) = DayReq(1, i);
        FinalState2 = StateInit * StatePbase35;
        StateInit = FinalState2;
        RecordIntSim(i, :) = FinalState2;
    end 

    % Interval 3 
    for i = 43:47
        StateInit(1, 1) = DayReq(1, i);
        FinalState2 = StateInit * StatePbase43;
        StateInit = FinalState2;
        RecordIntSim(i, :) = FinalState2;
    end 

    % Interval 4 
    for i = 48:49
        StateInit(1, 1) = DayReq(1, i);
        FinalState2 = StateInit * StatePt0;
        StateInit = FinalState2;
        RecordIntSim(i, :) = FinalState2;
    end
end

function [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = goodnessOfFitTest(RecordIntSim, n)
    % Perform GOF test and return counts
    CountyRet = sum(RecordIntSim(:, [9, 10, 11, 12]), 2);
    milwRealWorld = [11 11 45 2145 5678 10831 15034 20006 24039 27037 35090 44216 53637 63000 70734 72880 74440 84794 89209 96823 101581 106167 107781 109184 114679 122053 126777 132701 138382 139868 141069 148998 164360 179833 193998 206452 214636 219189 235695 250473 265685 282440 299610 307251 314011 319734 325547 325574 325587];

    [h, p] = kstest2(milwRealWorld, CountyRet);
    if h == 1 && p >= 0.05
        CU = 0; NCU = 0; CA = 0; NClate = 0; NCLost = 0; NCNoRet = 0; NCA = 0;
    else
        CU = round(RecordIntSim(end, 9));
        NCU = round(RecordIntSim(end, 11));
        CA = round(RecordIntSim(end, 10));
        NClate = round(RecordIntSim(end, 8));
        NCLost = round(RecordIntSim(end, 13));
        NCNoRet = round(RecordIntSim(end, 30));
        NCA = round(RecordIntSim(end, 12));
    end 
end
