'' momentums.bas -- port of FANN examples/momentums.c
'' Compares training results with different momentum values (0.0 - 0.6).

#include "../fann.bi"

const num_layers = 3ul
const num_neurons_hidden = 96ul
const desired_error = 0.001!
dim as fann ptr ann
dim as fann_train_data ptr train_data, test_data
dim as single momentum

train_data = fann_read_train_from_file("../datasets/robot.train")
test_data = fann_read_train_from_file("../datasets/robot.test")

momentum = 0.0
while momentum < 0.7
	printf(!"============= momentum = %f =============\n", cdbl(momentum))

	ann = fann_create_standard(num_layers, _
	        fann_num_input_train_data(train_data), num_neurons_hidden, _
	        fann_num_output_train_data(train_data))

	fann_set_training_algorithm(ann, FANN_TRAIN_INCREMENTAL)

	fann_set_learning_momentum(ann, momentum)

	fann_train_on_data(ann, train_data, 2000, 500, desired_error)

	printf(!"MSE error on train data: %f\n", cdbl(fann_test_data(ann, train_data)))
	printf(!"MSE error on test data : %f\n", cdbl(fann_test_data(ann, test_data)))

	fann_destroy(ann)

	momentum += 0.1
wend

fann_destroy_train(train_data)
fann_destroy_train(test_data)
