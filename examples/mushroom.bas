'' mushroom.bas -- port of FANN examples/mushroom.c
'' Classifies mushrooms as edible/poisonous (125 inputs, 2 outputs).

#include "../fann.bi"

const num_layers = 3ul
const num_neurons_hidden = 32ul
const desired_error = 0.0001!
const max_epochs = 300ul
const epochs_between_reports = 10ul
dim as fann ptr ann
dim as fann_train_data ptr train_data, test_data
dim as ulong i

printf(!"Creating network.\n")

train_data = fann_read_train_from_file("../datasets/mushroom.train")

ann = fann_create_standard(num_layers, _
        fann_num_input_train_data(train_data), num_neurons_hidden, _
        fann_num_output_train_data(train_data))

printf(!"Training network.\n")

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID)

fann_train_on_data(ann, train_data, max_epochs, epochs_between_reports, desired_error)

printf(!"Testing network.\n")

test_data = fann_read_train_from_file("../datasets/mushroom.test")

fann_reset_MSE(ann)
for i = 0 to fann_length_train_data(test_data) - 1
	fann_test(ann, fann_get_train_input(test_data, i), _
	               fann_get_train_output(test_data, i))
next

printf(!"MSE error on test data: %f\n", cdbl(fann_get_MSE(ann)))

printf(!"Saving network.\n")

fann_save(ann, "mushroom_float.net")

printf(!"Cleaning up.\n")
fann_destroy_train(train_data)
fann_destroy_train(test_data)
fann_destroy(ann)
