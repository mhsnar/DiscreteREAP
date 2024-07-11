function [Ad, Bd, Cd,Dd, NoS, NoI, NoO] = initialize(A, B, C, D, DeltaT)
    % Initialize and discretize system matrices
    G = ss(A, B, C, D);
    Gd = c2d(G, DeltaT);
    Ad = Gd.A;
    Bd = Gd.B;
    Cd = Gd.C;
    Dd=Gd.D;
    
    NoS = size(Ad, 1);
    NoI = size(Bd, 2);
    NoO = size(Cd, 1);

        Ad = [Ad Bd; zeros(NoI, NoS) zeros(NoI, NoI)];
    Bd = [zeros(NoS, NoI); eye(NoI)];
    Cd = [Cd Dd];

        NoS = size(Ad, 1);
    NoI = size(Bd, 2);
    NoO = size(Cd, 1);
end
