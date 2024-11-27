function DisREAP_UI_Example2()
clc
clear all
close all
% Create the figure for the UI
fig = uifigure('Name', 'Discrete REAP Input Interface', 'Position', [100 100 800 600]);

% Define default matrices
defaultMatrixA = [1 1;0 1];
defaultMatrixB = [0 0.5;1 0.5];
defaultMatrixC = [1 0];
defaultMatrixD =[0 0];
defaultMatrixQx = [1 0 ; 0 1];
defaultMatrixQu = [1 0;0 1];
defaultMatrixQv =    [100];


defaultMatrixUconstraintU=[10;10];
defaultMatrixUconstraintL=[-10;-10];
defaultMatrixX0Str=[  0;0];
defaultMatrixrStr=[4.85];
defaultMatrixXconstraintU=[5;5];
defaultMatrixXconstraintL=[-5;-5];

% Convert matrices to string representations
defaultMatrixAStr = mat2str(defaultMatrixA);
defaultMatrixBStr = mat2str(defaultMatrixB);
defaultMatrixCStr = mat2str(defaultMatrixC);
defaultMatrixDStr = mat2str(defaultMatrixD);
defaultMatrixQxStr = mat2str(defaultMatrixQx);
defaultMatrixQuStr = mat2str(defaultMatrixQu);
defaultMatrixQvStr = mat2str(defaultMatrixQv);
defaultMatrixUconstraintUStr=mat2str(defaultMatrixUconstraintU);
defaultMatrixUconstraintLStr=mat2str(defaultMatrixUconstraintL);
defaultMatrixXconstraintUStr=mat2str(defaultMatrixXconstraintU);
defaultMatrixXconstraintLStr=mat2str(defaultMatrixXconstraintL);
defaultMatrixX0Str=mat2str(defaultMatrixX0Str);
defaultMatrixrStr=mat2str(defaultMatrixrStr);


% First column
uilabel(fig, 'Text', 'Matrix A:', 'Position', [20 550 100 22]);
% uilabel(fig, 'Text', '[0 1;0 1]', 'Position',  [130 545 250 70]);
AInput = uitextarea(fig, 'Position', [130 500 250 70], 'Value', defaultMatrixAStr);

uilabel(fig, 'Text', 'Matrix B:', 'Position', [20 470 100 22]);
BInput = uitextarea(fig, 'Position', [130 420 250 70], 'Value', defaultMatrixBStr);

uilabel(fig, 'Text', 'Matrix C:', 'Position', [20 390 100 22]);
CInput = uitextarea(fig, 'Position', [130 340 250 70], 'Value', defaultMatrixCStr);

uilabel(fig, 'Text', 'Matrix D:', 'Position', [20 310 100 22]);
DInput = uitextarea(fig, 'Position', [130 260 250 70], 'Value', defaultMatrixDStr);


uilabel(fig, 'Text', 'X constraint U.B.:', 'Position', [20 230 100 22]);
XConstraintsU = uitextarea(fig, 'Position', [130 230 250 20],'Value', defaultMatrixXconstraintUStr);

uilabel(fig, 'Text', 'X constraint L.B.:', 'Position', [20 200 100 22]);
XConstraintsL = uitextarea(fig, 'Position', [130 200 250 20],'Value', defaultMatrixXconstraintLStr);

uilabel(fig, 'Text', 'U Constraints U.B:', 'Position', [20 170 100 22]);
UConstraintsU = uitextarea(fig, 'Position', [130 170 250 20],'Value', defaultMatrixUconstraintUStr);

uilabel(fig, 'Text', 'U constraint L.B.:', 'Position', [20 140 100 22]);
UConstraintsL = uitextarea(fig, 'Position', [130 140 250 20],'Value', defaultMatrixUconstraintLStr);


% Second column
uilabel(fig, 'Text', 'Matrix Qx:', 'Position', [420 550 100 22]);
QxInput = uitextarea(fig, 'Position', [530 500 250 70], 'Value', defaultMatrixQxStr);

uilabel(fig, 'Text', 'Matrix Qu:', 'Position', [420 470 100 22]);
QuInput = uitextarea(fig, 'Position', [530 420 250 70], 'Value', defaultMatrixQuStr);

% uilabel(fig, 'Text', 'Matrix Qv:', 'Position', [420 390 100 22]);
% QvInput = uitextarea(fig, 'Position', [530 340 250 70], 'Value', defaultMatrixQvStr);
uilabel(fig, 'Text', 'Initial Condistion:', 'Position', [420 390 100 22]);
x0 = uitextarea(fig, 'Position',[530 340 250 70], 'Value', defaultMatrixX0Str);







uilabel(fig, 'Text', 'Prediction Horizon:', 'Position', [420 310 150 22]);
PredictionHorizonInput = uieditfield(fig, 'numeric', 'Position', [530 310 250 22], 'Value', 10);


% Dropdown to select desired input type
uilabel(fig, 'Text', 'Desired Target:', 'Position', [420 280 150 22]);
InputTypeDropdown = uidropdown(fig, ...
    'Items', {'r (Reference)', 'xbar (Equilibrium Point)'}, ...
    'Position', [530 280 250 22]);

% Field for xbar (hidden initially)
uilabel(fig, 'Text', 'Equilibrium Point (xbar):', 'Position', [420 280 150 22], 'Visible', 'off', 'Tag', 'xbarLabel');
xbarInput = uitextarea(fig, 'Position', [530 280 250 22], 'Visible', 'off', 'Value', '[0; 0]', 'Tag', 'xbarInput');

uilabel(fig, 'Text', 'Desired:', 'Position',[420 250 100 22]);
r = uitextarea(fig, 'Position', [530 250 250 22], 'Value', defaultMatrixrStr);





% Omegastar input field
% uilabel(fig, 'Text', 'Omegastar:', 'Position', [420 120 100 22]);
% OmegastarInput = uieditfield(fig, 'numeric', 'Position', [530 120 250 22], 'Value', 20);

% Dropdown to select mode (Linear TC/Lyapanov TC)
uilabel(fig, 'Text', 'Terminal Constaint', 'Position', [420 150 100 22]);
ModeDropdown = uidropdown(fig, ...
    'Items', {'Prediction-Based', 'Lyapunov-Based'}, ...
    'Position', [530 150 250 22]);

% Nested function to toggle the OmegastarInput field


% Initialize Omegastar input state based on default dropdown value

%
% uilabel(fig, 'Text', 'Available Time:', 'Position', [420 210 100 22]);
% ATInput = uieditfield(fig, 'numeric', 'Position', [530 210 250 22], 'Value', 0.2);

uilabel(fig, 'Text', '# Time Instants:', 'Position', [420 210 100 22]);
nSimInput = uieditfield(fig, 'numeric', 'Position', [530 210 250 22], 'Value', 100);

%     uilabel(fig, 'Text', 'Initial Condistion:', 'Position', [420 180.5 100 22]);
% x0 = uitextarea(fig, 'Position', [530 180.5 250 22], 'Value', defaultMatrixX0Str);

uilabel(fig, 'Text', 'Sampling Period:', 'Position',  [420 180.5 100 22]);
DeltaTInput = uieditfield(fig, 'numeric', 'Position', [530 180.5 250 22], 'Value', 0.2);


% Add checkboxes for plot activation
uilabel(fig, 'Text', 'Select Plots:', 'Position', [20 100 100 22]);
checkbox1 = uicheckbox(fig, 'Text', 'States', 'Position', [130 100 100 22]);
checkbox2 = uicheckbox(fig, 'Text', 'Control Inputs', 'Position', [200 100 100 22]);
checkbox3 = uicheckbox(fig, 'Text', 'Output', 'Position', [130 70 100 22]);
checkbox4 = uicheckbox(fig, 'Text', 'Sigma', 'Position', [200 70 100 22]);

% Add a button to trigger the MPC calculation
btn = uibutton(fig, 'Text', 'Run REAP', 'Position', [350 30 100 20], ...
    'ButtonPushedFcn', @(btn, event) runMPCButtonPushed(AInput, BInput, CInput, DInput,XConstraintsU,XConstraintsL,UConstraintsU,UConstraintsL, x0,r,QxInput, QuInput, DeltaTInput, PredictionHorizonInput,InputTypeDropdown,ModeDropdown,nSimInput,checkbox1, checkbox2, checkbox3,checkbox4,xbarInput));

end

function runMPCButtonPushed(AInput, BInput, CInput, DInput,XConstraintsU,XConstraintsL,UConstraintsU,UConstraintsL,x0,r, QxInput, QuInput, DeltaTInput, PredictionHorizonInput,InputTypeDropdown,ModeDropdown,nSimInput,checkbox1, checkbox2, checkbox3,checkbox4,xbarInput)
% Parse the user inputs


A = str2num(char(AInput.Value)); %#ok<ST2NM>
B = str2num(char(BInput.Value)); %#ok<ST2NM>
C = str2num(char(CInput.Value)); %#ok<ST2NM>
D = str2num(char(DInput.Value)); %#ok<ST2NM>
XConstraints = [str2num(char(XConstraintsL.Value)), str2num(char(XConstraintsU.Value))]; %#ok<ST2NM>
UConstraints = [str2num(char(UConstraintsL.Value)),str2num(char(UConstraintsU.Value))]; %#ok<ST2NM>
x0 = str2num(char(x0.Value)); %#ok<ST2NM>
r = str2num(char(r.Value)); %#ok<ST2NM>
Qx = str2num(char(QxInput.Value)); %#ok<ST2NM>
Qu = str2num(char(QuInput.Value)); %#ok<ST2NM>
% Qv = str2num(char(QvInput.Value)); %#ok<ST2NM>
Qv=100;
Qv=eye(size(C, 1));
DeltaT = DeltaTInput.Value;
Prediction_Horizon = PredictionHorizonInput.Value;

% AT = ATInput.Value;
nSim = nSimInput.Value;






G = ss(A, B, C, D);
Gd = c2d(G, DeltaT);
Ad = Gd.A;
Bd = Gd.B;
Cd = Gd.C;
Dd = Gd.D;
NoS = size(Ad, 1);
NoI = size(Bd, 2);


if strcmp(InputTypeDropdown.Value, 'r (Reference)')
    % r = str2num(char(r.Value)); %#ok<ST2NM>
else
    % xbar = str2num(char(xbarInput.Value)); %#ok<ST2NM>
    r = desiredCalculation(Ad, Bd, Cd, Dd,NoS,NoI,r); % Call the function to compute r
end


Omegastar =  MPCFunctions.computeOmegastar(Ad, Bd,Cd,Dd,XConstraints,UConstraints,r, NoS,NoI, Qx, Qu); % Replace with actual algorithm


% Run the MPC
[x, u_app] = runMPC(A, B, C, D,XConstraints,UConstraints,x0,r, Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, nSim,checkbox1, checkbox2, checkbox3,checkbox4,ModeDropdown);

% Display results in a new figure
resultFig = uifigure('Name', 'MPC Results', 'Position', [600 100 400 600]);
uilabel(resultFig, 'Text', 'State Trajectories (x):', 'Position', [20 550 150 20]);
uitextarea(resultFig, 'Value', mat2str(x), 'Position', [20 300 360 250]);

uilabel(resultFig, 'Text', 'Applied Control Inputs (u_app):', 'Position', [20 270 200 20]);
uitextarea(resultFig, 'Value', mat2str(u_app), 'Position', [20 20 360 250]);


end


function [x, u_app] = runMPC(A, B, C, D,Xconstraint,Uconstraint, x0,r,Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, n,checkbox1, checkbox2, checkbox3,checkbox4,ModeDropdown)

% Main function to run the MPC

% Validate inputs
MPCFunctions.validateInputs(A, B, C, D, Qx, Qu, Qv, Xconstraint(:,end), Xconstraint(:,1), Uconstraint(:,end), Uconstraint(:,1), x0, r, n, DeltaT);

% Initialize parameters and states
[Ad, Bd, Cd,Dd, NoS, NoI, NoO] = MPCFunctions.initialize(A, B, C, D, DeltaT);

% Compute MPC
if strcmp(ModeDropdown.Value, 'Lyapunov-Based') 

[x, u_app,Sigmas] = MPCFunctions.computeMPCLyapanov(Ad, Bd, Cd,Dd,Xconstraint,Uconstraint,x0,r, NoS, NoI, NoO, Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, n);

else
[x, u_app,Sigmas] = MPCFunctions.computeMPC_Omegastar(Ad, Bd, Cd,Dd,Xconstraint,Uconstraint,x0,r, NoS, NoI, NoO, Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, n);

end
disp('REAP ended!');
disp('Plotting the graphs has started!...');
plotFlags = [checkbox1.Value, checkbox2.Value, checkbox3.Value,checkbox4.Value]; % Logical array for plot states
plott_EXP
disp('Plotting the graphs ended!');
end



function r = desiredCalculation(Ad, Bd, Cd, Dd,NoS,NoI,xbar)

X=[Ad-eye(length(Ad)) Bd zeros(length(Ad),size(Cd,1));...
    Cd Dd -eye(size(Cd,1),size(Cd,1))];

MN=null(X,"rational");

M1=MN(1:NoS,:);
N=MN(1+NoS+NoI:end,:);
Theta=pinv(M1)*xbar;
r=N*Theta;
end
