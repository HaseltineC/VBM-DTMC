

%    Markov Chain which is time inhomogeneous 
%  X13 - Malicious loss of marked ballot   
 

function [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = VBMDTMC_X13(rr, a, init4, init4e, M3str, M4str, M6str, M7str, DSn, AttackDay, AStrength)
    % Define the number of states
    n = 30;
    
    % Initialize state transition matrices for various conditions
    StatePbase = initializeStatePbase(n, init4, rr, a, M3str, M4str, M7str);
    StatePbase35 = adjustForInPersonAbsentee(StatePbase, M6str, init4e, rr);
    StatePbase43 = adjustNoLateBallotMail(StatePbase35);
    StatePt0 = initializeStatePt0(n, M7str);
    StatePMalAttack = applyMaliciousAttack(StatePbase, AStrength, a);
    StatePMalAttack35 = applyMaliciousAttack(StatePbase35, AStrength, a);
    StatePMalAttack43 = applyMaliciousAttack(StatePbase43, AStrength, a);
    StatePMalAttackPt0 = applyMaliciousAttack(StatePt0, AStrength, 0);

    % Simulate the election cycle
    [CU, NCU, CA, NClate, NCLost, NCNoRet, NCA] = modelElectionCycle(DSn, AttackDay, ...
        StatePbase, StatePbase35, StatePbase43, StatePt0, ...
        StatePMalAttack, StatePMalAttack35, StatePMalAttack43, StatePMalAttackPt0);

end

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

function StatePbase35 = adjustForInPersonAbsentee(StatePbase, M6str, init4e, rr)
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

function StatePMalAttack = applyMaliciousAttack(StatePbase, AStrength, a)
    StatePMalAttack = StatePbase;
    StatePMalAttack(6, 7) = StatePbase(6,7) - (AStrength + a);
    StatePMalAttack(6, 6) = StatePbase(6,6);
    StatePMalAttack(6, 24) = AStrength + a;
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
end
