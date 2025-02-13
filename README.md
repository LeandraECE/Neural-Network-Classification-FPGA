# Neural Network Image Classifier on FPGA
This project implements a hardware-based neural network in Vivado to classify 32×32 binary images of handwritten digits using a 3-layer architecture. The classification uses the MNIST dataset subset and is designed for deployment on the Basys3 FPGA development board.

## Neural Network Architecture:
1. Input:
   - 1024 neurons (32×32 pixels).
   - Pixels are represented as 1-bit binary values (0 = white, 1 = black).
2. Hidden Layer: 32 neurons with ReLU activation.
3. Output Layer: 10 neurons for digit classification.
![Captura de ecrã 2025-02-12 142539](https://github.com/user-attachments/assets/e9a21229-397e-41d9-ab73-756105b9dc26)


## Memory System:
Three pre-initialized memories:
- Input Memory: 3,840×32-bit, storing rows of binary images.
- Weights for Hidden Layer (FC1): 1024×128-bit (dual port), storing 4-bit weights for the hidden layer.
- Weights for Output Layer (FC2): 80×32-bit (dual port), storing 8-bit weights for the output layer.
The memorys are in the IP folder and the Coefficient Files folder contains the files with the image and weights data.

## Usage
To build the project, source the provided TCL script:
```sh
source NN_classification.tcl
```
