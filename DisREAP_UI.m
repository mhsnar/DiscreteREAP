function DisREAP_UI()
clc
clear all
close all
    % Create the figure for the UI
    fig = uifigure('Name', 'Discrete REAP Input Interface', 'Position', [100 100 800 600]);

  

    % First column
    uilabel(fig, 'Text', 'Matrix A:', 'Position', [20 550 100 22]);
    % uilabel(fig, 'Text', '[0 1;0 1]', 'Position',  [130 545 250 70]);
    AInput = uitextarea(fig, 'Position', [130 500 250 70]);

    uilabel(fig, 'Text', 'Matrix B:', 'Position', [20 470 100 22]);
    BInput = uitextarea(fig, 'Position', [130 420 250 70]);

    uilabel(fig, 'Text', 'Matrix C:', 'Position', [20 390 100 22]);
    CInput = uitextarea(fig, 'Position', [130 340 250 70]);

    uilabel(fig, 'Text', 'Matrix D:', 'Position', [20 310 100 22]);
    DInput = uitextarea(fig, 'Position', [130 260 250 70]);

    uilabel(fig, 'Text', 'Constraints on X:', 'Position', [20 220 100 22]);
    XConstraints = uitextarea(fig, 'Position', [130 200 250 40]);

    uilabel(fig, 'Text', 'Constraints on U:', 'Position', [20 160 100 22]);
    UConstraints = uitextarea(fig, 'Position', [130 140 250 40]);

    % Second column
    uilabel(fig, 'Text', 'Matrix Qx:', 'Position', [420 550 100 22]);
    QxInput = uitextarea(fig, 'Position', [530 500 250 70]);

    uilabel(fig, 'Text', 'Matrix Qu:', 'Position', [420 470 100 22]);
    QuInput = uitextarea(fig, 'Position', [530 420 250 70]);
    % 
    % uilabel(fig, 'Text', 'Matrix Qv:', 'Position', [420 390 100 22]);
    % QvInput = uitextarea(fig, 'Position', [530 340 250 70]);
        uilabel(fig, 'Text', 'Initial Condistions:', 'Position',  [420 390 100 22]);
    x0 = uitextarea(fig, 'Position', [530 340 250 70]);

        uilabel(fig, 'Text', 'Desired:', 'Position', [420 310 100 22]);
    r = uitextarea(fig, 'Position', [530 310 250 22]);


    uilabel(fig, 'Text', 'Prediction Horizon:', 'Position', [420 270 150 22]);
    PredictionHorizonInput = uieditfield(fig, 'numeric', 'Position', [530 270 250 22]);

    uilabel(fig, 'Text', 'Omegastar:', 'Position', [420 238.5 100 22]);
    OmegastarInput = uieditfield(fig, 'numeric', 'Position', [530 238.5 250 22]);

    % uilabel(fig, 'Text', 'Available Time:', 'Position', [420 210 100 22]);
    % ATInput = uieditfield(fig, 'numeric', 'Position', [530 210 250 22], 'Value', 0.2);

    uilabel(fig, 'Text', '# Time Instants:', 'Position', [420 210 100 22]);
    nSimInput = uieditfield(fig, 'numeric', 'Position', [530 210 250 22]);

    %     uilabel(fig, 'Text', 'Initial Condistion:', 'Position', [420 180.5 100 22]);
    % x0 = uitextarea(fig, 'Position', [530 180.5 250 22]);


    uilabel(fig, 'Text', 'Sampling Period:', 'Position', [420 180.5 100 22]);
    DeltaTInput = uieditfield(fig, 'numeric', 'Position', [530 180.5 250 22]);

    % Add a button to trigger the MPC calculation
    btn = uibutton(fig, 'Text', 'Run REAP', 'Position', [350 30 100 20], ...
        'ButtonPushedFcn', @(btn, event) runMPCButtonPushed(AInput, BInput, CInput, DInput,XConstraints,UConstraints, x0,r,QxInput, QuInput, DeltaTInput, PredictionHorizonInput, OmegastarInput, nSimInput));
   
end

function runMPCButtonPushed(AInput, BInput, CInput, DInput,XConstraints,UConstraints,x0,r, QxInput, QuInput, DeltaTInput, PredictionHorizonInput, OmegastarInput, nSimInput)
    % Parse the user inputs
   

   A = str2num(char(AInput.Value)); %#ok<ST2NM>
    B = str2num(char(BInput.Value)); %#ok<ST2NM>
    C = str2num(char(CInput.Value)); %#ok<ST2NM>
    D = str2num(char(DInput.Value)); %#ok<ST2NM>
    XConstraints = str2num(char(XConstraints.Value)); %#ok<ST2NM>
    UConstraints = str2num(char(UConstraints.Value)); %#ok<ST2NM>
        x0 = str2num(char(x0.Value)); %#ok<ST2NM>
    r = str2num(char(r.Value)); %#ok<ST2NM>
    Qx = str2num(char(QxInput.Value)); %#ok<ST2NM>
    Qu = str2num(char(QuInput.Value)); %#ok<ST2NM>
    % Qv = str2num(char(QvInput.Value)); %#ok<ST2NM>
    Qv = 100;
    DeltaT = DeltaTInput.Value;
    Prediction_Horizon = PredictionHorizonInput.Value;
    Omegastar = OmegastarInput.Value;
    % AT = ATInput.Value;
    nSim = nSimInput.Value;

    % Run the MPC (this is a placeholder for your actual MPC function)
    [x, u_app] = runMPC(A, B, C, D,XConstraints,UConstraints,x0,r, Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, nSim);
    
    % Display results in a new figure
    resultFig = uifigure('Name', 'MPC Results', 'Position', [600 100 400 600]);
    uilabel(resultFig, 'Text', 'State Trajectories (x):', 'Position', [20 550 150 20]);
    uitextarea(resultFig, 'Value', mat2str(x), 'Position', [20 300 360 250]);

    uilabel(resultFig, 'Text', 'Applied Control Inputs (u_app):', 'Position', [20 270 200 20]);
    uitextarea(resultFig, 'Value', mat2str(u_app), 'Position', [20 20 360 250]);
end


function [x, u_app] = runMPC(A, B, C, D,Xconstraint,Uconstraint, x0,r,Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, n)

    % Main function to run the MPC

    % Validate inputs
    MPCFunctions.validateInputs(A, B, C, D, Qx, Qu, Qv);

    % Initialize parameters and states
    [Ad, Bd, Cd,Dd, NoS, NoI, NoO] = MPCFunctions.initialize(A, B, C, D, DeltaT);

    % Compute MPC
    [x, u_app] = MPCFunctions.computeMPC(Ad, Bd, Cd,Dd,Xconstraint,Uconstraint,x0,r, NoS, NoI, NoO, Qx, Qu, Qv, DeltaT, Prediction_Horizon, Omegastar, n);
    plott_EXP
end

