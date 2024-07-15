# Discrete Robust to Early Termination Model Predictive Control (DisREAP)

## 🛠️ Getting Started:
1. **Extract the YALMIP zip file** to your desired location.
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

## Citing ERGT:


If you use the ERG Toolbox, please use the following BibTeX entry:
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERGT Citation</title>
    <style>
        .code-container {
            position: relative;
        }
        .copy-button {
            position: absolute;
            top: 0;
            right: 0;
            padding: 5px;
            cursor: pointer;
            background: #eee;
            border: 1px solid #ccc;
        }
    </style>
</head>
<body>
    <h1>Citing ERGT</h1>
    <p>If you use the ERG Toolbox, please use the following BibTeX entry:</p>
    <div class="code-container">
        <button class="copy-button" onclick="copyToClipboard()">Copy</button>
        <pre><code id="bibtex">

@INPROCEEDINGS{Amiri:DiscreteREAP,
AUTHOR="Andr{\'e}s {Mohsen Amiri and Mehdi Hosseinzadeh",
TITLE="Discrete-Time Implementation of Robust-to-Early Termination Model Predictive Control",
BOOKTITLE="..... ",
ADDRESS="........",

ABSTRACT="........."
}

        </code></pre>
    </div>
    <script>
        function copyToClipboard() {
            const code = document.getElementById('bibtex').innerText;
            navigator.clipboard.writeText(code).then(() => {
                alert('Copied to clipboard!');
            });
        }
    </script>
</body>
</html>



## 🤝 Support:
For any issues or questions, please refer to the [issues page](https://github.com/mhsnar/DiscreteREAP/issues) on GitHub.
