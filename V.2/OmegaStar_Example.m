clear
close all
clc

Kx1=-0.052701624162968;
Kx2=-5.477869892924388;
Ky1=-0.018687914020970;
Ky2=-7.060834512263481;
Kz1=-1.787280741456883;
Kz2=-1.738212699869965;
A=[0   1   0   0   0   0
    0  Kx1  0   0   0   0
    0   0   0   1   0   0
    0   0   0   Ky1 0   0
    0   0   0   0   0   1
    0   0   0   0   0  Kz1];
B=[0   0   0
    Kx2  0   0
    0   0   0
    0  Ky2  0
    0   0   0
    0   0  Kz2];

C=[1	0	0	0	0	0
    0	1	0	0	0	0
    0	0	1	0	0	0
    0	0	0	1	0	0
    0	0	0	0	1	0
    0	0	0	0	0	1];
D=[0	0	0
    0	0	0
    0	0	0
    0	0	0
    0	0	0
    0	0	0];

r = [0;0;0;0;1.5;0];

DeltaT=0.2;

G=ss(A,B,C,D);
Gd=c2d(G,DeltaT);
A=Gd.A;
B=Gd.B;
C=Gd.C;
D=Gd.D;


Ad=A;
Bd=B;
Cd=C;
%
NoS=size(Ad,1);
NoI=size(Bd,2);
NoO=size(Cd,1);

Qx=5*eye(size(A,1));
Qx=[5 0 0 0 0 0;0 5 0 0 0 0;0 0 5 0 0 0; 0 0 0 5 0 0;0 0 0 0 1000 0; 0 0 0 0 0 1000];
Qu=[35 0 0 ;0 20 0;0 0 1];
% Qu=.001*eye(size(B,2));
% Qu=[35 0 0 ;0 35 0;0 0 60];

beta=100;
[Qn,K,~,~] = idare(Ad,Bd,Qx,Qu,[],[]);
K=-K;
% desired_poles = [0.9 + 0.1i, 0.9 - 0.1i, 0.85 + 0.2i, 0.85 - 0.2i, 0.8, 0.7];
% K = -place(Ad, Bd, desired_poles);

M1=[1	0	0
    0	0	0
    0	1	0
    0	0	0
    0	0	1
    0	0	0];
M2=[0	0	0
    0	0	0
    0	0	0];
N=[1	0	0
    0	0	0
    0	1	0
    0	0	0
    0	0	1
    0	0	0];

Uconstraint=[.05 .05 .6]';


Xconstraint=[10 10 2.57 10 10 10]';
Xconstraint_down=[-10 -10 -2.57 -10 0 -10]';

x_up=Xconstraint;
x_down=Xconstraint_down;

for Omegastar=0:100
    clear TConstraints_cost TConstraints x

    yalmip('clear')
    ssss=M1(1:NoS,:);
    if size(ssss,1)==size(ssss,2)
        theta=inv(ssss)*r;
    else
        theta=pinv(ssss)*r;
    end
    theta = sdpvar(3,1,'full');
    x=sdpvar(6,1,'full');

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
        CbarTu2=-(M2*theta-K*M1*theta)-Uconstraint+1/beta;
        for i=1:Omegastar
            Sig=zeros(size(Bd,2),1);
            Sigg=zeros(size(Bd,2),1);
            for j=1:i
                Sig=Sig+K*(Ad+Bd*K)^(j-1)*(Bd*M2*theta-Bd*K*M1*theta);
                Sigg=Sigg+K*(Ad+Bd*K)^(j)*(Bd*M2*theta-Bd*K*M1*theta);
            end
            CbarTu1=[CbarTu1;Sig+M2*theta-K*M1*theta-Uconstraint+1/beta];
            CbarTu2=[CbarTu2;-(Sig+M2*theta-K*M1*theta)-Uconstraint+1/beta];
            CbarTu1_T=[Sigg+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta];
            CbarTu2_T=[-(Sigg+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)-Uconstraint+1/beta];
        end


   
        TUConstraints1_omega=AbarTu*x+CbarTu1;
        TUConstraints2_omega=-AbarTu*x+CbarTu2;



        TConstraints=[TXConstraints1_omega;TXConstraints2_omega;TUConstraints1_omega;TUConstraints2_omega]<=0;

    TConstraints = [TConstraints;M2*theta<=0.98*Uconstraint-1/beta;M2*theta>=-0.98*Uconstraint+1/beta;M1*theta<=0.98*Xconstraint-1/beta;M1*theta>=0.98*Xconstraint_down+1/beta];

    if Omegastar==0
        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+(Bd*M2*theta-Bd*K*M1*theta)-Xconstraint+1/beta;-((Ad+Bd*K)^(Omegastar+1))*x-(Bd*M2*theta-Bd*K*M1*theta)+Xconstraint_down+1/beta;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta;-K*((Ad+Bd*K)^(Omegastar+1))*x-(K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)-Uconstraint+1/beta];

    elseif Omegastar==1

        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+CbarTx1_T;-((Ad+Bd*K)^(Omegastar+1))*x+CbarTx2_T;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+K*(Ad+Bd*K)*(Bd*M2*theta-Bd*K*M1*theta)+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta-Uconstraint+1/beta;-K*((Ad+Bd*K)^(Omegastar+1))*x-(K*(Ad+Bd*K)*(Bd*M2*theta-Bd*K*M1*theta)+K*(Bd*M2*theta-Bd*K*M1*theta)+M2*theta-K*M1*theta)-Uconstraint+1/beta];

    else
        TConstraints_cost=[((Ad+Bd*K)^(Omegastar+1))*x+CbarTx1_T;-((Ad+Bd*K)^(Omegastar+1))*x+CbarTx2_T;...
                           K*((Ad+Bd*K)^(Omegastar+1))*x+CbarTu1_T;-K*((Ad+Bd*K)^(Omegastar+1))*x+CbarTu2_T];
    end


    TXConstraints1_eps= M1*theta-0.98*Xconstraint+1/beta;
    TXConstraints2_eps= -M1*theta+0.98*Xconstraint_down+1/beta;
    TUConstraints1_eps=M2*theta-0.98*Uconstraint+1/beta;
    TUConstraints2_eps=- M2*theta-0.98*Uconstraint+1/beta;

    TConstraints_cost = [TConstraints_cost;TXConstraints1_eps;TXConstraints2_eps;TUConstraints1_eps;TUConstraints2_eps];    % % If we have theta

    for i=1:length(TConstraints_cost)
        cons=TConstraints_cost(i);
        sigma=-cons;
        options = sdpsettings('solver', 'fmincon');
        sol=optimize(TConstraints,sigma,options);
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