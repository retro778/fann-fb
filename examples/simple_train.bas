'' simple_train.bas -- port of FANN examples/simple_train.c
'' Minimal training example: train XOR from a data file and save the net.

#include "../fann.bi"

const num_input = 2ul
const num_output = 1ul
const num_layers = 3ul
const num_neurons_hidden = 3ul
const desired_error = 0.001!
const max_epochs = 500000ul
const epochs_between_reports = 1000ul

dim as fann ptr ann = fann_create_standard(num_layers, num_input, num_neurons_hidden, num_output)

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC)

fann_train_on_file(ann, "xor.data", max_epochs, epochs_between_reports, desired_error)

fann_save(ann, "xor_float.net")

fann_destroy(ann)
