'' robot_adam.bas -- port of FANN examples/robot_adam.c
'' Same robot dataset, trained with the Adam optimizer.

#include "../fann.bi"

const num_layers = 3ul
const num_neurons_hidden = 96ul
const desired_error = 0.00001!
dim as fann ptr ann
dim as fann_train_data ptr train_data, test_data
dim as ulong i

printf(!"Creating network.\n")

train_data = fann_read_train_from_file("../datasets/robot.train")

ann = fann_create_standard(num_layers, _
        fann_num_input_train_data(train_data), num_neurons_hidden, _
        fann_num_output_train_data(train_data))

printf(!"Training network.\n")

fann_set_training_algorithm(ann, FANN_TRAIN_ADAM)
fann_set_adam_beta1(ann, 0.9)
fann_set_adam_beta2(ann, 0.999)
fann_set_adam_epsilon(ann, 1e-8)
fann_set_learning_rate(ann, 0.05)

fann_train_on_data(ann, train_data, 10000, 100, desired_error)

printf(!"Testing network.\n")

test_data = fann_read_train_from_file("../datasets/robot.test")

fann_reset_MSE(ann)
for i = 0 to fann_length_train_data(test_data) - 1
	fann_test(ann, fann_get_train_input(test_data, i), _
	               fann_get_train_output(test_data, i))
next
printf(!"MSE error on test data: %f\n", cdbl(fann_get_MSE(ann)))

printf(!"Saving network.\n")

fann_save(ann, "robot_adam.net")

printf(!"Cleaning up.\n")
fann_destroy_train(train_data)
fann_destroy_train(test_data)
fann_destroy(ann)
