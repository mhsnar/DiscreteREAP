clear
close all
clc



Xconstraint=[10000, 1 ]';
Xconstraint_down=[-1 ,-10000 ]';




x_up=Xconstraint;
AA=[.5 1;0 .3];
CC=[1 0;1 1];

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
    if Omegastar>=1
        x_up=[x_up;Xconstraint]
        x_down=[x_down;Xconstraint_down]
    end

  

    TXConstraints1_omega=AbarTx*x-x_up;
    TXConstraints2_omega=-AbarTx*x+x_down;

    

    % Constraint=[CC*x<=x_up;CC*x>=x_down];
  
    TConstraints=[TXConstraints1_omega,TXConstraints2_omega]<=0;

    % TConstraints = [Constraint;TConstraints];


    % Constraint=[CC*x-x_up;-CC*x+x_down];

    TConstraints_cost=[CC*(AA^(Omegastar+1))*x-Xconstraint;-CC*(AA^(Omegastar+1))*x+Xconstraint_down];



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