clear
close all
clc



Xconstraint=[5 ]';
Xconstraint_down=[-.5 ]';




x_up=Xconstraint;
AA=[.4 -.1;-.2 .5];
CC=[-1 .2];

x_down=Xconstraint_down;

for Omegastar=0:100
    clear TConstraints_cost TConstraints x
    AbarTx=CC;
    for i=1:Omegastar
        AbarTx=[AbarTx;CC*(AA)^(i)];
    end


    %% Costraints

    yalmip('clear')
    % theta = sdpvar(3,1,'full');
    % x = sdpvar(6,1,'full');
    % x=[x;0;0;0];

    x=sdpvar(2,1,'full');

    TXConstraints1_omega=AbarTx*x-x_up;
    TXConstraints2_omega=-AbarTx*x+x_down;

    

    % Constraint=[CC*x<=x_up;CC*x>=x_down];
  
    TConstraints=[TXConstraints1_omega;TXConstraints2_omega]<=0;

    % TConstraints = [Constraint;TConstraints];


    % Constraint=[CC*x-x_up;-CC*x+x_down];

    TConstraints_cost=[CC*(AA^(Omegastar+1))*x-x_up;-CC*(AA^(Omegastar+1))*x+x_down];



    % TConstraints_cost = [Constraint;TConstraints_cost];


      
    for i=1:length(TConstraints_cost)
        cons=TConstraints_cost(i);
        con=-cons;
     
        sigma=con;
        options = sdpsettings('solver', 'fmincon');


        sol=optimize(TConstraints,sigma,options);
        J(i)=double(-sigma);
        if J(i)>0
            break
        end

    end

    if J <= 0
        Omegastar
        break
    end

end
fprintf('Omegastar: %f\n', Omegastar);