'' scaling_train.bas -- port of FANN examples/scaling_train.c
'' Demonstrates FANN's built-in input/output scaling: the raw dataset is
'' scaled to [-1,1] with parameters stored inside the network file.

#include "../fann.bi"

const num_input = 3ul
const num_output = 1ul
const num_layers = 4ul
const num_neurons_hidden = 5ul
const desired_error = 0.0001!
const max_epochs = 5000ul
const epochs_between_reports = 1000ul
dim as fann_train_data ptr data_ = 0

dim as fann ptr ann = fann_create_standard(num_layers, num_input, _
        num_neurons_hidden, num_neurons_hidden, num_output)

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_LINEAR)
fann_set_training_algorithm(ann, FANN_TRAIN_RPROP)

data_ = fann_read_train_from_file("../datasets/scaling.data")

fann_set_scaling_params( _
        ann, _
        data_, _
        -1, _   '' New input minimum
        1, _    '' New input maximum
        -1, _   '' New output minimum
        1)      '' New output maximum

fann_scale_train(ann, data_)

fann_train_on_data(ann, data_, max_epochs, epochs_between_reports, desired_error)
fann_destroy_train(data_)
fann_save(ann, "scaling.net")
fann_destroy(ann)
