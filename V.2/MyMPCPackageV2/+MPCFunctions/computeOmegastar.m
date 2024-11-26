function Omegastar = computeOmegastar(Ad, Bd,Cd,Dd,Xconstraints,Uconstraints,r, NoS,NoI, Qx, Qu)




disp('Automatic Calculation of OmegaStar has started!...');
beta=100;
[~,K,~,~] = idare(Ad,Bd,Qx,Qu,[],[]);
K=-K;
% desired_poles = [0.9 + 0.1i, 0.9 - 0.1i, 0.85 + 0.2i, 0.85 - 0.2i, 0.8, 0.7];
% K = -place(Ad, Bd, desired_poles);




X=[Ad-eye(length(Ad)) Bd zeros(length(Ad),size(Cd,1));...
    Cd Dd -eye(size(Cd,1),size(Cd,1))];

MN=null(X,"rational");


M1=MN(1:NoS,:);
M2=MN(1+NoS:+NoS+NoI,:);


N=MN(1+NoS+NoI:end,:);


% Xconstraint_down=[-10 -10 -2.57 -10 0 -10]';
Xconstraint_down=Xconstraints(:,1);
Xconstraint=Xconstraints(:,end);

Uconstraint_down=Uconstraints(:,1);
Uconstraint=Uconstraints(:,end);

for Omegastar=0:100
    clear TConstraints_cost TConstraints x

    yalmip('clear')
    % ssss=M1(1:NoS,:);
    % if size(ssss,1)==size(ssss,2)
    %     theta=inv(ssss)*r;
    % else
    %     theta=pinv(ssss)*r;
    % end
    theta=pinv(N)*r;
    % theta = sdpvar(3,1,'full');
    x=sdpvar(NoS,1,'full');

    AbarTx=eye(length(x),length(x));
    for i=1:Omegastar
        AbarTx=[AbarTx;(Ad+Bd*K)^(i)];
    end



        AbarTu=K;
        for i=1:Omegastar
            AbarTu=[AbarTu;K*((Ad+Bd*K))^(i)];
        end




    %% Costraints

    xbar=M1*theta;
    ubar=M2*theta;
    V=N*theta;

    CbarTx1=-Xconstraint+1/beta;
    CbarTx2=+Xconstraint_down+1/beta;
    for i=1:Omegastar
        Sig=zeros(size(Ad,1),1);
        Sigg=zeros(size(Ad,2),1);
        for j=1:i
            Sig=Sig+(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
            Sigg=Sigg+(Ad+Bd*K)^(j)*(Bd*M2*theta-Bd*K*M1*theta);
        end
        CbarTx1=[CbarTx1;Sig-Xconstraint+1/beta];
        CbarTx2=[CbarTx2;-Sig+Xconstraint_down+1/beta];
        CbarTx1_T=Sigg+(Bd*M2*theta-Bd*K*M1*theta)-Xconstraint+1/beta;
        CbarTx2_T=-Sigg-(Bd*M2*theta-Bd*K*M1*theta)+Xconstraint_down+1/beta;
    end
    TXConstraints1_omega=AbarTx*x+CbarTx1;
    TXConstraints2_omega=-AbarTx*x+CbarTx2;






        CbarTu1=M2*theta-K*M1*theta-Uconstraint+1/beta;
        CbarTu2=-(M2*theta-K*M1*theta)+Uconstraint_down+1/beta;
        for i=1:Omegastar
            Sig=zeros(size(Bd,2),1);
            Sigg=zeros(size(Bd,2),1);
            for j=1:i
                Sig=Sig+K*(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
                Sigg=Sigg+K*(Ad+Bd*K)^(j)*(Bd*M2*theta-Bd*K*M1*theta);
            end
            CbarTu1=[CbarTu1;Sig+M2*theta-K*M1*theta-Uconstraint+1/beta];
            CbarTu2=[CbarTu2;-(Sig+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];
            CbarTu1_T=[Sigg+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta];
            CbarTu2_T=[-(Sigg+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];
        end


   
        TUConstraints1_omega=AbarTu*x+CbarTu1;
        TUConstraints2_omega=-AbarTu*x+CbarTu2;



        TConstraints=[TXConstraints1_omega;TXConstraints2_omega;TUConstraints1_omega;TUConstraints2_omega]<=0;

    % TConstraints = [TConstraints;M2*theta<=0.98*Uconstraint-1/beta;M2*theta>=-0.98*Uconstraint+1/beta;M1*theta<=0.98*Xconstraint-1/beta;M1*theta>=-0.98*Xconstraint+1/beta];

    if Omegastar==0
        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+(Bd*M2*theta-Bd*K*M1*theta)-Xconstraint+1/beta;-((Ad+Bd*K)^(Omegastar+1))*x-(Bd*M2*theta-Bd*K*M1*theta)+Xconstraint_down+1/beta;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta;-K*((Ad+Bd*K)^(Omegastar+1))*x-(K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];

    elseif Omegastar==1

        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+CbarTx1_T;-((Ad+Bd*K)^(Omegastar+1))*x+CbarTx2_T;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+K*(Ad+Bd*K)*(Bd*M2*theta-Bd*K*M1*theta)+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta;-K*((Ad+Bd*K)^(Omegastar+1))*x-(K*(Ad+Bd*K)*(Bd*M2*theta-Bd*K*M1*theta)+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];

    else
        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+CbarTx1_T;-((Ad+Bd*K)^(Omegastar+1))*x+CbarTx2_T;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+CbarTu1_T;-K*((Ad+Bd*K)^(Omegastar+1))*x+CbarTu2_T];
    end


    TXConstraints1_eps= M1*theta-0.98*Xconstraint+1/beta;
    TXConstraints2_eps= -M1*theta+0.98*Xconstraint_down+1/beta;
    TUConstraints1_eps=M2*theta-0.98*Uconstraint+1/beta;
    TUConstraints2_eps=- M2*theta+0.98*+Uconstraint_down+1/beta;

    % TConstraints_cost = [TConstraints_cost;TXConstraints1_eps;TXConstraints2_eps;TUConstraints1_eps;TUConstraints2_eps];    % % If we have theta

    for i=1:length(TConstraints_cost)
        cons=TConstraints_cost(i);
        sigma=-cons;
        options = sdpsettings('solver', 'fmincon','showprogress',0,'verbose',0);
        optimize(TConstraints,sigma,options);
        J(i)=double(-sigma);

        if J(i)>0
            break
        end
    end

    if J <= 0
        break
    end

end
fprintf('Omegastar: %f\n', Omegastar);
disp('Automatic Calculation of OmegaStar ended!');
    % Placeholder for the algorithm to compute Omegastar

end