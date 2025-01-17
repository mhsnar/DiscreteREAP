# Discrete Robust to Early Termination Model Predictive Control (DisREAP)

## 🛠️ Getting Started:
1. **Extract the YALMIP zip file** to the location of the DisREAP file.
2. **Run the `DisREAP_UI` function** in MATLAB.

## 🚀 Usage:
1. **Import your system and desired configurations**:
   - After running `DisREAP_UI`, import your system model and specify your desired configurations.
2. **Execute the package** to start the control process.

## 📚 Examples:
For guidance, the package includes two examples:
1. **Parrot Bebop 2 Drone**:
   - This example demonstrates the implementation of DisREAP on a Parrot Bebop 2 drone.
2. **Second-Order Dynamic System Benchmark**:
   - This example showcases DisREAP applied to a second-order dynamic system.

## ▶️ Running Examples:
1. **Navigate to the examples directory**:
   - Open the folder containing the examples within the extracted files.
2. **Run the example scripts**:
   - Follow the instructions in the example scripts to see the results and understand how to set up and execute your own system.

## 🤝 Support:
For any issues or questions, please refer to the [issues page](https://github.com/mhsnar/DiscreteREAP/issues) on GitHub.

## Citing DisREAP:

If you use the DisREAP Toolbox, please use the following BibTeX entry:
```bibtex

@article{AMIRI2025106018,
title = {Practical considerations for implementing robust-to-early termination model predictive control},
journal = {Systems & Control Letters},
volume = {196},
pages = {106018},
year = {2025},
issn = {0167-6911},
doi = {https://doi.org/10.1016/j.sysconle.2024.106018},
url = {https://www.sciencedirect.com/science/article/pii/S0167691124003062},
author = {Mohsen Amiri and Mehdi Hosseinzadeh},
keywords = {Model predictive control, Robust-to-early termination, Discrete-time implementation, Limited computing capacity},
abstract = {Model Predictive Control (MPC) is widely used to achieve performance objectives, while enforcing operational and safety constraints. Despite its high performance, MPC often demands significant computational resources, making it challenging to implement in systems with limited computing capacity. A recent approach to address this challenge is to use the Robust-to-Early Termination (REAP) strategy. At any time instant, REAP converts the MPC problem into the evolution of a virtual dynamical system whose trajectory converges to the optimal solution, and provides guaranteed sub-optimal and feasible solution whenever its evolution is terminated due to limited computational power. REAP has been introduced as a continuous-time scheme and its theoretical properties have been derived under the assumption that it performs all the computations in continuous time. However, REAP should be practically implemented in discrete-time. This paper focuses on the discrete-time implementation of REAP, exploring conditions under which anytime feasibility and convergence properties are maintained when the computations are performed in discrete time. The proposed methodology is validated and evaluated through extensive simulation and experimental studies.}
}





