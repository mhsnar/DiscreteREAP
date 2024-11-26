function [x, u_app,Sigmas] = computeMPCLyapanov(Ad, Bd, Cd,Dd,Xconstraints,Uconstraints,x0,r, NoS, NoI, NoO, Qx, Qu, Qv, DeltaT, Prediction_Horizion, Omegastar, n,C)
% Compute MPC control action
% Implement the MPC logic here based on the provided code
disp('REAP has started!...');
% Initialize variables

u_des=zeros(NoI,1);
% Initial conditions and reference

x(:, 1) = [x0;zeros(NoI,1)];

% Discretized system matrices for augmented system
Xconstraint_down=Xconstraints(:,1);
Xconstraint=Xconstraints(:,end);

Uconstraint_down=Uconstraints(:,1);
Uconstraint=Uconstraints(:,end);
% State and control constraints
Xconstraint = [Xconstraint;1000* ones(NoI,1)];
Xconstraint_down=[Xconstraint_down;-1000* ones(NoI,1)];

% Extended matrices for prediction horizon
QxBar = blkdiag(kron(eye(Prediction_Horizion), Qx));
QuBar = blkdiag(kron(eye(Prediction_Horizion), Qu));
Qx=[Qx zeros(size(Qx,1),size(Qu,1));zeros(size(Qu,1),size(Qx,1)) Qu];

[Qn,K,~,~] = idare(Ad,Bd,Qx,Qu,[],[]);
K=-K;
psi=dlyap((Ad+Bd*K)',eye(NoS));

% Placeholder for control input
u_app = zeros(NoI, n);
X=[Ad-eye(length(Ad)) Bd zeros(length(Ad),size(Cd,1));...
    Cd Dd -eye(size(Cd,1),size(Cd,1))];

MN=null(X,"rational");


M1=MN(1:NoS-NoI,:);
M2=MN(1+NoS:+NoS+NoI,:);
M1=[M1;M2];

N=MN(1+NoS+NoI:end,:);



% Calculating x_pr:
Abar=Ad;
for i=2:Prediction_Horizion
    Abar=[Abar;Ad^(i)];
end

[o, m] = size(Bd);
Bbar = zeros(o * Prediction_Horizion, m * Prediction_Horizion);

for i = 1:Prediction_Horizion
    for j = 1:i
        A_power = Ad^(i-j);

        % Element-wise multiplication using matrix multiplication
        block = A_power * Bd;

        % Calculate the indices for insertion
        row_indices = (i-1)*o + 1 : i*o;
        col_indices = (j-1)*m + 1 : j*m;

        % Insert the block into the appropriate position in Bbar
        Bbar(row_indices, col_indices) = block;
    end
end

beta=100;



x_up=[];
u_up=[];
u_down=[];
x_down=[];
for i=1:Prediction_Horizion
    u_up=[u_up;Uconstraint];
    u_down=[u_down;Uconstraint_down];

    x_up=[x_up;Xconstraint];
    x_down=[x_down;Xconstraint_down];
end
% u_down=-u_up;
% x_down=-x_up;

% Create QuBar using blkdiag
QuBar = blkdiag(kron(eye(Prediction_Horizion), Qu));
QxBar = blkdiag(kron(eye(Prediction_Horizion), Qx));


M1Bar=M1;
M2Bar=M2;
for i=1:Prediction_Horizion-1
    M1Bar=[M1Bar;M1];
    M2Bar=[M2Bar;M2];
end

AbarTx=(Ad+Bd*K);
for i=2:Omegastar
    AbarTx=[AbarTx;(Ad+Bd*K)^(i)];
end

BbarTx=AbarTx*Bbar(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion,:);
AbarTx=AbarTx*Abar(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion,:); %new modified

AbarTu=K;
for i=1:Omegastar-1
    AbarTu=[AbarTu;K*((Ad+Bd*K))^(i)];
end
BbarTu=AbarTu*Bbar(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion,:);
AbarTu=AbarTu*Abar(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion,:); %new modified

Number_of_Constraints=(Prediction_Horizion+Omegastar+1)*(2*size(Xconstraint,1)+2*size(Uconstraint,1));


hat_lambda=zeros(Number_of_Constraints,1);

hat_lambda_x1=zeros(size(Xconstraint,1)*(Prediction_Horizion),1);
hat_lambda_x2=zeros(size(Xconstraint,1)*Prediction_Horizion,1);
hat_lambda_u1=zeros(size(Uconstraint,1)*Prediction_Horizion,1);
hat_lambda_u2=zeros(size(Uconstraint,1)*Prediction_Horizion,1);

hat_lambda_omega_x1=zeros(size(Xconstraint,1)*(Omegastar),1);
hat_lambda_omega_x2=zeros(size(Xconstraint,1)*(Omegastar),1);
hat_lambda_omega_u1=zeros(size(Uconstraint,1)*(Omegastar),1);
hat_lambda_omega_u2=zeros(size(Uconstraint,1)*(Omegastar),1);

hat_lambda_omega_x1_eps=zeros(size(Xconstraint,1),1);
hat_lambda_omega_x2_eps=zeros(size(Xconstraint,1),1);
hat_lambda_omega_u1_eps=zeros(size(Uconstraint,1),1);
hat_lambda_omega_u2_eps=zeros(size(Uconstraint,1),1);

hat_u=zeros(Prediction_Horizion*size(Uconstraint,1),1);
hatLambda.x1=hat_lambda_x1;
hatLambda.x2=hat_lambda_x2;
hatLambda.u1=hat_lambda_u1;
hatLambda.u2=hat_lambda_u2;
hatLambda.omega_x1=hat_lambda_omega_x1;
hatLambda.omega_x2=hat_lambda_omega_x2;
hatLambda.omega_u1=hat_lambda_omega_u1;
hatLambda.omega_u2=hat_lambda_omega_u2;
hatLambda.omega_x1_eps=hat_lambda_omega_x1_eps;
hatLambda.omega_x2_eps=hat_lambda_omega_x2_eps;
hatLambda.omega_u1_eps=hat_lambda_omega_u1_eps;
hatLambda.omega_u2_eps=hat_lambda_omega_u2_eps;
%%
flag=0;
f=1;
eta=0.001;
sign=[];
Sigmas = [];
Sigmass = [];
sigma_values=[];

for inc=1:n
     
    theta=pinv(N)*r;

    xbar=M1*theta;
    ubar=M2*theta;
    V=N*theta;

    %
    if inc==1
        x0=x(:,inc);

    elseif inc>1
        % x0=[x(1,inc);(x(1,inc)-x(1,inc-1))/DeltaT;x(3,inc);(x(3,inc)-x(3,inc-1))/DeltaT;x(5,inc);(x(5,inc)-x(5,inc-1))/DeltaT;u_app(:,inc-1)];
        x0=x(:,inc);
    end

    %% Terminal Conditions
    if inc==1 %Optimization
        yalmip('clear')
        % theta = sdpvar(3,1,'full');
        % theta=[r(1) r(3) r(5)]';
        hat_u = sdpvar(NoI*Prediction_Horizion,1,'full');
        xbar=M1*theta;
        ubar=M2*theta;
        V=N*theta;
        x0=x(:,1);
        x_pr =Abar*x0+Bbar*hat_u ;
        % x_pr =Bbar * hat_u ;
        errV=V-r;
        ErrorV=(errV'*Qv*errV);
        norU=ubar-u_des;
        NormU= (norU'*norU);
        errU = hat_u - M2Bar*theta;
        ErrorU = errU' * QuBar * errU;
        errX = x_pr - M1Bar*theta;
        ErrorX = errX' * QxBar * errX;
        errTX = x_pr(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion) - xbar;
        ErrorTX = errTX' * Qn * errTX;
        sigma = ErrorV+ErrorU + ErrorX + ErrorTX + NormU;
        % Terminal Conditions
        CbarTx1=[];
        CbarTx2=[];
        for i=1:Omegastar
            Sig=zeros(size(Ad,1),1);
            for j=1:i
                Sig=Sig+(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
            end
            CbarTx1=[CbarTx1;Sig-Xconstraint+1/beta];
            CbarTx2=[CbarTx2;-Sig+Xconstraint_down+1/beta];
        end
        TXConstraints1=(AbarTx*x0+BbarTx*hat_u+CbarTx1);
        TXConstraints2=-(AbarTx*x0+BbarTx*hat_u)+CbarTx2;

        CbarTu1=M2*theta-K*M1*theta-Uconstraint+1/beta;
        CbarTu2=-(M2*theta-K*M1*theta)+Uconstraint_down+1/beta;
        for i=1:Omegastar-1
            Sig=zeros(size(Bd,2),1);
            for j=1:i
                Sig=Sig+K*(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
            end
            CbarTu1=[CbarTu1;Sig+M2*theta-K*M1*theta-Uconstraint+1/beta];
            CbarTu2=[CbarTu2;-(Sig+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];
        end
        TUConstraints1=AbarTu*x0+BbarTu*hat_u+CbarTu1;
        TUConstraints2=-(AbarTu*x0+BbarTu*hat_u)+CbarTu2;

        TConstraints=[TXConstraints1;TXConstraints2;TUConstraints1;TUConstraints2]<=0;
        TConstraints = [TConstraints;M2*theta<=0.98*Uconstraint-1/beta;M2*theta>=+0.98*Uconstraint_down+1/beta;M1*theta<=0.98*Xconstraint-1/beta;M1*theta>=0.98*Xconstraint_down+1/beta];

        Constraint=[x_pr<=x_up-1/beta;x_pr>=x_down+1/beta;hat_u<=u_up-1/beta;hat_u>=u_down+1/beta];

        Constraints=[Constraint;TConstraints];
        opt=sdpsettings('showprogress',0,'verbose',0);
        sol=optimize(Constraints,sigma,opt);
        clear x_pr Constraint Constraints x_pr errU
        hat_u=double(hat_u);
    else
    end



    AT=DeltaT-0.05;   %Available Time for Primal_dual_gradient_flow

    if inc==1
        u_app=zeros(NoI,1);
    elseif inc>1
        %
    end

    tic;
    %Samplingtime
    MM=0;
    hat_u0=hat_u;
    hatLambda0=hatLambda;
    sigma_hat_u0 = CostF(r,u_des,x0,inc,Abar,Bbar,M1Bar,M2Bar,hat_u0,QxBar,QuBar,Qn,Qv,Prediction_Horizion,NoS,DeltaT,M1,M2,N,u_app,theta);
    % Primal_dual_gradient_flow
    sigma_values=[];
    while toc<AT
        % for MMM=1:100

        x_pr =Abar*x0+Bbar*hat_u ;
        errV=V-r;
        ErrorV=(errV'*Qv*errV);
        norU=ubar-u_des;
        NormU= (norU'*norU);
        errU = hat_u - M2Bar*theta;
        ErrorU = errU' * QuBar * errU;
        errX = x_pr - M1Bar*theta;
        ErrorX = errX' * QxBar * errX;
        errTX = x_pr(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion) - xbar;
        ErrorTX = errTX' * Qn * errTX;

        TXConstraints1_eps= M1*theta-0.98*Xconstraint+1/beta;
        TXConstraints2_eps= -M1*theta+0.98*Xconstraint_down+1/beta;
        TUConstraints1_eps=M2*theta-0.98*Uconstraint+1/beta;
        TUConstraints2_eps=- M2*theta+0.98*Uconstraint_down+1/beta;

         CbarTx1=[];
            CbarTx2=[];
            for i=1:Omegastar
                Sig=zeros(size(Ad,1),1);
                for j=1:i
                    Sig=Sig+(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
                end
                CbarTx1=[CbarTx1;Sig-Xconstraint+1/beta];
                CbarTx2=[CbarTx2;-Sig+Xconstraint_down+1/beta];
            end
            TXConstraints1=AbarTx*x0+BbarTx*hat_u+CbarTx1;
            TXConstraints2=-(AbarTx*x0+BbarTx*hat_u)+CbarTx2;
         % 
         %    % AbarTx*x0+BbarTx*hat_u+CbarTx1+Xconstraint-1/beta
         %    % 
         %    CbarTu1=M2*theta-K*M1*theta-Uconstraint+1/beta;
         %    CbarTu2=-(M2*theta-K*M1*theta)+Uconstraint_down+1/beta;
         %    for i=1:Omegastar-1
         %        Sig=zeros(size(Bd,2),1);
         %        for j=1:i
         %            Sig=Sig+K*(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
         %        end
         %        CbarTu1=[CbarTu1;Sig+M2*theta-K*M1*theta-Uconstraint+1/beta];
         %        CbarTu2=[CbarTu2;-(Sig+M2*theta-K*M1*theta)+Uconstraint_down+1/beta];
         %    end
         %    TUConstraints1=AbarTu*x0+BbarTu*hat_u+CbarTu1;
         %    TUConstraints2=-(AbarTu*x0+BbarTu*hat_u)+CbarTu2;

         invpsi=inv(psi);
         err=x_pr(size(Ad,1)*Prediction_Horizion-(size(Ad,1)-1):size(Ad,1)*Prediction_Horizion)-xbar;
         LyapanovF=(err)'*psi*(err);

         TXConstraints1=[];
         TXConstraints2=[];
         coeff=eye(NoS);
        
         for inc=1:NoS
             TXConstraints1=[TXConstraints1;LyapanovF-((xbar(inc)-Xconstraint(inc))^2/(coeff(inc,:)*invpsi*coeff(inc,:)'))];
             TXConstraints2=[TXConstraints2;LyapanovF-((-xbar(inc)+Xconstraint_down(inc))^2/(coeff(inc,:)*invpsi*coeff(inc,:)'))];
         end

         TUConstraints1=[];
         TUConstraints2=[];
         for incc=1:NoI
             TUConstraints1 = [TUConstraints1;LyapanovF-((ubar(incc)-Uconstraint(incc))^2/(K(incc,:)*invpsi*K(incc,:)'))];
             TUConstraints2 = [TUConstraints2;LyapanovF-((-ubar(incc)+Uconstraint_down(incc))^2/(K(incc,:)*invpsi*K(incc,:)'))];
         end

   
         % Constraints1 = [LyapanovF<=(xbar(1)-(5))^2/([1 0]*inv(psi)*[1;0])];
         % Constraints2 = [LyapanovF<=(-xbar(1)-(5))^2/([1 0]*inv(psi)*[1;0])];
         %    Constraints3 = [LyapanovF<=(ubar(1)-.3)^2/(K(1,:)*inv(psi)*K(1,:)')];
         %    Constraints4 = [LyapanovF<=(-ubar(1)-.3)^2/(K(1,:)*inv(psi)*K(1,:)')];
         % 
         %    Constraints1 = [Constraints1;LyapanovF<=(xbar(2)-(5))^2/([0 1]*inv(psi)*[0;1])];
         %    Constraints2 = [Constraints2;LyapanovF<=(-xbar(2)-(5))^2/([0 1]*inv(psi)*[0;1])];
         %    Constraints3 = [Constraints3;LyapanovF<=(ubar(2)-.3)^2/(K(2,:)*inv(psi)*K(2,:)')];
         %    Constraints4 = [Constraints4;LyapanovF<=(-ubar(2)-.3)^2/(K(2,:)*inv(psi)*K(2,:)')];

            

            AllConstraints.Tx1=TXConstraints1;
            AllConstraints.Tx2=TXConstraints2;
            AllConstraints.Tu1=TUConstraints1;
            AllConstraints.Tu2=TUConstraints2;
            AllConstraints.Tx1_eps=TXConstraints1_eps;
            AllConstraints.Tx2_eps=TXConstraints2_eps;
            AllConstraints.Tu1_eps=TUConstraints1_eps;
            AllConstraints.Tu2_eps=TUConstraints2_eps;
        %% X and U and T constraints

        A1x=ones(size(x_pr));
        A2x=-1*ones(size(x_pr));
        B1x=-1*ones(size(x_pr));
        B2x=1*ones(size(x_pr));
        Cu1=ones(size(hat_u));
        Cu2=-1*ones(size(hat_u));
        D1u=-1*ones(size(hat_u));
        D2u=ones(size(hat_u));

        XConstraints1=A1x.*x_pr+B1x.*x_up+1/beta;
        XConstraints2=A2x.*x_pr+B2x.*x_down+1/beta;
        UConstraints1=Cu1.*hat_u+D1u.*u_up+1/beta;
        UConstraints2=Cu2.*hat_u+D2u.*u_down+1/beta;

        AllConstraints.x1=XConstraints1;
        AllConstraints.x2=XConstraints2;
        AllConstraints.u1=UConstraints1;
        AllConstraints.u2=UConstraints2;
        AllConstraints.Ax1=A1x;
        AllConstraints.Ax2=A2x;
        AllConstraints.Bx1=B1x;
        AllConstraints.Bx2=B2x;
        AllConstraints.Cu1=Cu1;
        AllConstraints.Cu2=Cu2;
        AllConstraints.Du1=D1u;
        AllConstraints.Du2=D2u;

         epsilon=eps;
            delX=min(max([XConstraints1;XConstraints2]-1/beta+epsilon),0);
            delU=min(max([UConstraints1;UConstraints2]-1/beta+epsilon),0);
            delTX=min(max([TXConstraints1;TXConstraints2]-1/beta+epsilon),0);
            delTU=min(max([TUConstraints1;TUConstraints2]-1/beta+epsilon),0);
            if MM==47
                d=2;
            end
            if any(delU==0) || any(delTU==0)
                ddd=MM+1000000000000;
            else
            end
            if inc==1 && MM==13
                d=1;
            end

                        % Compute gradients of the objective function
            grad_B_u = gradient_B_u(Bbar, errU,errX,errTX, QuBar,QxBar, NoS,hatLambda, Prediction_Horizion,AllConstraints,beta,Qn,BbarTx,BbarTu);
            grad_B_lambda = gradient_B_lambda( AllConstraints, beta);

            [minValue, minIndex] = max([delX, delU, delTX, delTU]);

            dell=[abs(delX)/norm(Bd);abs(delU);abs(delTX)/(norm(BbarTx));abs(delTU)/(norm(BbarTu))];
               
ds=0.001;
            gammaD=1;
            flag_gammaD=0;
            while flag_gammaD==0
                    if any([gammaD*dell(minIndex);gammaD*dell(minIndex);gammaD*dell(minIndex);gammaD*dell(minIndex)]>dell)
                        gammaD=gammaD-0.1;
                    else
                        flag_gammaD=1;
                    end
            end
              

            Sigma=gammaD*dell(minIndex)/(ds*max(norm(grad_B_u),eta));
 
            gamma=1;


            Checkpoint=grad_B_lambda+ Phi(hatLambda,grad_B_lambda,hat_lambda);
            gammaD=1;
            flag_gammaD=0;
            while flag_gammaD==0
                    if any((hat_lambda+ds*Sigma*Checkpoint)<0)
                        Sigma=0.95*Sigma;
                    else
                        flag_gammaD=1;
                    end
            end


            kh=hat_lambda+ds*Sigma*(grad_B_lambda+ Phi(hatLambda,grad_B_lambda,hat_lambda));


            sigma_values=[sigma_values;Sigma];
            
            hat_u= hat_u- ds*Sigma*grad_B_u;
            if any(hat_lambda<0)
                xa=1;
            else
            end


               
            % norm((grad_B_lambda+ Phi(hatLambda,grad_B_lambda)));
            hat_lambda=hat_lambda+ds*Sigma*(grad_B_lambda+ Phi(hatLambda,grad_B_lambda,hat_lambda));




            if any(hat_lambda<0)
                xa=1;
            else
            end
            % for kk=1:length(hat_lambda)
            % if hat_lambda(kk)<=0
            %     hat_lambda(kk)=0;
            % else
            % end
            % end
            

            
            hat_lambda_x1=hat_lambda(1: size(XConstraints1));
            hat_lambda_x2=hat_lambda(size(XConstraints1)+1:2*size(XConstraints1));
            hat_lambda_u1=hat_lambda(1+2*size(XConstraints1):2*size(XConstraints1)+size(UConstraints1));
            hat_lambda_u2=hat_lambda(1+2*size(XConstraints1)+size(UConstraints1):2*size(XConstraints1)+2*size(UConstraints1));
            hat_lambda_omega_x1=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1):2*size(XConstraints1)+2*size(UConstraints1)+size(TXConstraints1));
            hat_lambda_omega_x2=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+size(TXConstraints1):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1));
            hat_lambda_omega_u1=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+size(TUConstraints1));
            hat_lambda_omega_u2=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+size(TUConstraints1):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1));
            hat_lambda_omega_x1_eps=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+size(TXConstraints1_eps));
            hat_lambda_omega_x2_eps=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+size(TXConstraints1_eps):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+2*size(TXConstraints1_eps));
            hat_lambda_omega_u1_eps=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+2*size(TXConstraints1_eps):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+2*size(TXConstraints1_eps)+size(TUConstraints1_eps));
            hat_lambda_omega_u2_eps=hat_lambda(1+2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+2*size(TXConstraints1_eps)+size(TUConstraints1_eps):2*size(XConstraints1)+2*size(UConstraints1)+2*size(TXConstraints1)+2*size(TUConstraints1)+2*size(TXConstraints1_eps)+2*size(TUConstraints1_eps));

            hatLambda.x1=hat_lambda_x1;
            hatLambda.x2=hat_lambda_x2;
            hatLambda.u1=hat_lambda_u1;
            hatLambda.u2=hat_lambda_u2;
            hatLambda.omega_x1=hat_lambda_omega_x1;
            hatLambda.omega_x2=hat_lambda_omega_x2;
            hatLambda.omega_u1=hat_lambda_omega_u1;
            hatLambda.omega_u2=hat_lambda_omega_u2;
            hatLambda.omega_x1_eps=hat_lambda_omega_x1_eps;
            hatLambda.omega_x2_eps=hat_lambda_omega_x2_eps;
            hatLambda.omega_u1_eps=hat_lambda_omega_u1_eps;
            hatLambda.omega_u2_eps=hat_lambda_omega_u2_eps;
            % pause(0.005);
            % i=i+1;
            MM=MM+1;
    end
   
    % MM
    
    Sigmas{inc} = sigma_values;  % Store all Sigma values for the current increment


    %Acceptance,Rejection
    sigma_hat_u = CostF(r,u_des,x0,inc,Abar,Bbar,M1Bar,M2Bar,hat_u,QxBar,QuBar,Qn,Qv,Prediction_Horizion,NoS,DeltaT,M1,M2,N,u_app,theta);
    if sigma_hat_u<=sigma_hat_u0
        hatLambda=hatLambda;
        hat_u=hat_u;
    else
        hatLambda=hatLambda0;
        hat_u=hat_u0;
    end
    %Warm Starting
    hat_u_0=[];
    hat_lambda_x1_0=[];
    hat_lambda_x2_0=[];
    hat_lambda_u1_0=[];
    hat_lambda_u2_0=[];
    hat_lambda_omega_x1_0=[];
    hat_lambda_omega_x2_0=[];
    hat_lambda_omega_u1_0=[];
    hat_lambda_omega_u2_0=[];
    hat_lambda_omega_x1_eps_0=[];
    hat_lambda_omega_x2_eps_0=[];
    hat_lambda_omega_u1_eps_0=[];
    hat_lambda_omega_u2_eps_0=[];

    hat_lambda_x1=hatLambda.x1;
    hat_lambda_x2=hatLambda.x2;
    hat_lambda_u1=hatLambda.u1;
    hat_lambda_u2=hatLambda.u2;
    hat_lambda_omega_x1=hatLambda.omega_x1;
    hat_lambda_omega_x2=hatLambda.omega_x2;
    hat_lambda_omega_u1=hatLambda.omega_u1;
    hat_lambda_omega_u2=hatLambda.omega_u2;
    hat_lambda_omega_x1_eps=hatLambda.omega_x1_eps;
    hat_lambda_omega_x2_eps=hatLambda.omega_x2_eps;
    hat_lambda_omega_u1_eps=hatLambda.omega_u1_eps;
    hat_lambda_omega_u2_eps=hatLambda.omega_u2_eps;




    for p=1:Prediction_Horizion-1
        hat_u_0=[hat_u_0;hat_u(NoI*p+1:NoI*p+NoI)];
        hat_lambda_x1_0=[hat_lambda_x1_0;hat_lambda_x1(NoS*p+1:NoS*p+NoS)];
        hat_lambda_x2_0=[hat_lambda_x2_0;hat_lambda_x2(NoS*p+1:NoS*p+NoS)];
        hat_lambda_u1_0=[hat_lambda_u1_0;hat_lambda_u1(NoI*p+1:NoI*p+NoI)];
        hat_lambda_u2_0=[hat_lambda_u2_0;hat_lambda_u2(NoI*p+1:NoI*p+NoI)];
    end
    for p=1:Omegastar-1
        hat_lambda_omega_x1_0=[hat_lambda_omega_x1_0;hat_lambda_omega_x1(NoS*p+1:NoS*(p+1))];
        hat_lambda_omega_x2_0=[hat_lambda_omega_x2_0;hat_lambda_omega_x2(NoS*p+1:NoS*(p+1))];
        hat_lambda_omega_u1_0=[hat_lambda_omega_u1_0;hat_lambda_omega_u1(NoI*p+1:NoI*(p+1))];
        hat_lambda_omega_u2_0=[hat_lambda_omega_u2_0;hat_lambda_omega_u2(NoI*p+1:NoI*(p+1))];

    end
    %the same

    hat_lambda_omega_x1_eps_0=hat_lambda_omega_x1_eps;
    hat_lambda_omega_x2_eps_0=hat_lambda_omega_x2_eps;
    hat_lambda_omega_u1_eps_0=hat_lambda_omega_u1_eps;
    hat_lambda_omega_u2_eps_0=hat_lambda_omega_u2_eps;


    hat_u_0=[hat_u_0; M2*theta+K*(x_pr(NoS*Prediction_Horizion-NoS+1:NoS*Prediction_Horizion)-M1*theta)];
    hat_lambda_x1_0=[hat_lambda_x1_0;hat_lambda_x1(NoS*Prediction_Horizion-NoS+1:NoS*Prediction_Horizion)];
    hat_lambda_x2_0=[hat_lambda_x2_0;hat_lambda_x2(NoS*Prediction_Horizion-NoS+1:NoS*Prediction_Horizion)];
    hat_lambda_u1_0=[hat_lambda_u1_0;hat_lambda_u1(NoI*Prediction_Horizion-NoI+1:NoI*Prediction_Horizion)];
    hat_lambda_u2_0=[hat_lambda_u2_0;hat_lambda_u2(NoI*Prediction_Horizion-NoI+1:NoI*Prediction_Horizion)];
    hat_lambda_omega_x1_0=[hat_lambda_omega_x1_0;hat_lambda_omega_x1(NoS*Omegastar-NoS+1:NoS*Omegastar)];
    hat_lambda_omega_x2_0=[hat_lambda_omega_x2_0;hat_lambda_omega_x2(NoS*Omegastar-NoS+1:NoS*Omegastar)];
    hat_lambda_omega_u1_0=[hat_lambda_omega_u1_0;hat_lambda_omega_u1(NoI*Omegastar-NoI+1:NoI*Omegastar)];
    hat_lambda_omega_u2_0=[hat_lambda_omega_u2_0;hat_lambda_omega_u2(NoI*Omegastar-NoI+1:NoI*Omegastar)];
    hatLambda.x1=hat_lambda_x1_0;
    hatLambda.x2=hat_lambda_x2_0;
    hatLambda.u1=hat_lambda_u1_0;
    hatLambda.u2=hat_lambda_u2_0;
    hatLambda.omega_x1=hat_lambda_omega_x1_0;
    hatLambda.omega_x2=hat_lambda_omega_x2_0;
    hatLambda.omega_u1=hat_lambda_omega_u1_0;
    hatLambda.omega_u2=hat_lambda_omega_u2_0;
    hatLambda.omega_x1_eps=hat_lambda_omega_x1_eps_0;
    hatLambda.omega_x2_eps=hat_lambda_omega_x2_eps_0;
    hatLambda.omega_u1_eps=hat_lambda_omega_u1_eps_0;
    hatLambda.omega_u2_eps=hat_lambda_omega_u2_eps_0;


    u_app(:,inc)=double(hat_u(1:NoI));
    x(:,inc+1)=Ad*x(:,inc)+Bd*u_app(:,inc);
    theta_p=double(theta);
    %Update
    hat_u=hat_u_0;

end



 function grad_B_u = gradient_B_u(Bbar, errU,errX,errTX, QuBar,QxBar, NoS,hatLambda, Prediction_Horizion,AllConstraints,beta,Qn,BbarTx,BbarTu)
XConstraints1=AllConstraints.x1;
XConstraints2=AllConstraints.x2;
UConstraints1=AllConstraints.u1;
UConstraints2=AllConstraints.u2;
TXConstraints1=AllConstraints.Tx1;
TXConstraints2=AllConstraints.Tx2;
TUConstraints1=AllConstraints.Tu1;
TUConstraints2=AllConstraints.Tu2;
Ax1=AllConstraints.Ax1;
Ax2=AllConstraints.Ax2;
Cu1=AllConstraints.Cu1;
Cu2=AllConstraints.Cu2;

hat_lambda_x1=hatLambda.x1;
hat_lambda_x2=hatLambda.x2;
hat_lambda_u1=hatLambda.u1;
hat_lambda_u2=hatLambda.u2;
hat_lambda_omega_x1=hatLambda.omega_x1;
hat_lambda_omega_x2=hatLambda.omega_x2;
hat_lambda_omega_u1=hatLambda.omega_u1;
hat_lambda_omega_u2=hatLambda.omega_u2;
hat_lambda_omega_x1_eps=hatLambda.omega_x1_eps;
hat_lambda_omega_x2_eps=hatLambda.omega_x2_eps;
hat_lambda_omega_u1_eps=hatLambda.omega_u1_eps;
hat_lambda_omega_u2_eps=hatLambda.omega_u2_eps;


% Gradient with respect to u
grad_B_u = 2 * QuBar * errU  + 2 * Bbar' *QxBar * errX +2 * Bbar(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion,:)' *Qn * errTX;
grad_B_u = grad_B_u...
    - Bbar'*(hat_lambda_x1 .* (-beta) .*Ax1 ./ (-beta * XConstraints1+ 1))...
    - Bbar'*(hat_lambda_x2 .* (-beta) .*Ax2 ./ (-beta * XConstraints2 + 1))...
    - hat_lambda_u1 .* (-beta) .* Cu1 ./ (-beta * UConstraints1 + 1)...
    - hat_lambda_u2 .* (-beta) .* Cu2 ./ (-beta * UConstraints2 + 1)...
    - (BbarTx')*(hat_lambda_omega_x1 .* (-beta)  ./ (-beta * TXConstraints1+ 1))...
    - (-BbarTx')*(hat_lambda_omega_x2 .* (-beta)  ./ (-beta * TXConstraints2+ 1))...
    - (BbarTu')*(hat_lambda_omega_u1 .* (-beta)  ./ (-beta * TUConstraints1+ 1))...
    - (-BbarTu')*(hat_lambda_omega_u2 .* (-beta)  ./ (-beta * TUConstraints2+ 1));

% TXConstraints1 = M1*theta-0.98*Xconstraint+1/beta;
% TXConstraints2 = -M1*theta-0.98*Xconstraint+1/beta;
% TUConstraints1 = M2*theta-0.98*Uconstraint+1/beta;
% TUConstraints2 =- M2*theta-0.98*Uconstraint+1/beta;
end

function grad_B_lambda = gradient_B_lambda( AllConstraints, beta)
XConstraints1=AllConstraints.x1;
XConstraints2=AllConstraints.x2;
UConstraints1=AllConstraints.u1;
UConstraints2=AllConstraints.u2;
TXConstraints1=AllConstraints.Tx1;
TXConstraints2=AllConstraints.Tx2;
TUConstraints1=AllConstraints.Tu1;
TUConstraints2=AllConstraints.Tu2;

TXConstraints1_eps=AllConstraints.Tx1_eps;
TXConstraints2_eps=AllConstraints.Tx2_eps;
TUConstraints1_eps=AllConstraints.Tu1_eps;
TUConstraints2_eps=AllConstraints.Tu2_eps;






grad_B_lambda =  [-log10(-beta * XConstraints1 + 1);-log10(-beta * XConstraints2 + 1);...
    -log10(-beta * UConstraints1 + 1); -log10(-beta * UConstraints2 + 1);...
    -log10(-beta * TXConstraints1 + 1);-log10(-beta * TXConstraints2 + 1);...
    -log10(-beta * TUConstraints1 + 1); -log10(-beta * TUConstraints2 + 1);...
    -log10(-beta * TXConstraints1_eps + 1);-log10(-beta * TXConstraints2_eps + 1);...
    -log10(-beta * TUConstraints1_eps + 1); -log10(-beta * TUConstraints2_eps + 1)];


% grad_B_lambda(XConstraints1 > 1/beta) = -100;

end
%% Calculate Phi
function phi = Phi(hatLambda,grad_B_lambda,hat_lambda)
hat_lambda_x1=hatLambda.x1;
hat_lambda_x2=hatLambda.x2;
hat_lambda_u1=hatLambda.u1;
hat_lambda_u2=hatLambda.u2;
hat_lambda_omega_x1=hatLambda.omega_x1;
hat_lambda_omega_x2=hatLambda.omega_x2;
hat_lambda_omega_u1=hatLambda.omega_u1;
hat_lambda_omega_u2=hatLambda.omega_u2;
hat_lambda_omega_x1_eps=hatLambda.omega_x1_eps;
hat_lambda_omega_x2_eps=hatLambda.omega_x2_eps;
hat_lambda_omega_u1_eps=hatLambda.omega_u1_eps;
hat_lambda_omega_u2_eps=hatLambda.omega_u2_eps;
% Adjust gradients based on conditions for Phi(s)
lambda = [hat_lambda_x1;hat_lambda_x2;hat_lambda_u1;hat_lambda_u2...
    ;hat_lambda_omega_x1;hat_lambda_omega_x2;hat_lambda_omega_u1;hat_lambda_omega_u2;hat_lambda_omega_x1_eps;hat_lambda_omega_x2_eps;hat_lambda_omega_u1_eps;hat_lambda_omega_u2_eps] ;

for k=1:length(hat_lambda)
    if lambda(k) > 0  || (lambda(k)== 0  && grad_B_lambda(k)>= 0)
   phi(k) = 0; % Set to zero based on conditions
    else

        phi(k) = -grad_B_lambda(k); 
    end
end

phi=phi';
end

function sigma = CostF(r,u_des,x0,inc,Abar,Bbar,M1Bar,M2Bar,hat_u,QxBar,QuBar,Qn,Qv,Prediction_Horizion,NoS,DeltaT,M1,M2,N,u_app,theta)

xbar=M1*theta;
ubar=M2*theta;
V=N*theta;
% if inc==1
%     x0=x(:,1);
% elseif inc>1
%     x0=[x(1,inc);(x(1,inc)-x(1,inc-1))/DeltaT;x(3,inc);(x(3,inc)-x(3,inc-1))/DeltaT;x(5,inc);(x(5,inc)-x(5,inc-1))/DeltaT;u_app(:,inc-1)];
% end
x_pr =Abar*x0+Bbar*hat_u ;
errV=V-r;
ErrorV=(errV'*Qv*errV);
norU=ubar-u_des;
NormU= (norU'*norU);
errU = hat_u - M2Bar*theta;
ErrorU = errU' * QuBar * errU;
errX = x_pr - M1Bar*theta;
ErrorX = errX' * QxBar * errX;
errTX = x_pr(NoS * Prediction_Horizion - (NoS-1):NoS * Prediction_Horizion) - xbar;
ErrorTX = errTX' * Qn * errTX;
sigma = ErrorV+ErrorU + ErrorX + ErrorTX + NormU;
end

end
