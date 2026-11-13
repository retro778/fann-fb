'' cascade_train.bas -- port of FANN examples/cascade_train.c
'' Cascade-correlation training on the parity-8 problem: the network
'' starts with no hidden neurons and grows them one at a time.

#include "../fann.bi"

dim as fann ptr ann
dim as fann_train_data ptr train_data, test_data
const desired_error = 0.0!
dim as ulong max_neurons = 30
dim as ulong neurons_between_reports = 1
dim as ulong bit_fail_train, bit_fail_test
dim as single mse_train, mse_test
dim as ulong i
dim as fann_type ptr output_
dim as fann_type steepness
dim as long multi = 0
dim as fann_activationfunc_enum activation
dim as fann_train_enum training_algorithm = FANN_TRAIN_RPROP

printf(!"Reading data.\n")

train_data = fann_read_train_from_file("../datasets/parity8.train")
test_data = fann_read_train_from_file("../datasets/parity8.test")

fann_scale_train_data(train_data, -1, 1)
fann_scale_train_data(test_data, -1, 1)

printf(!"Creating network.\n")

ann = fann_create_shortcut(2, fann_num_input_train_data(train_data), _
                              fann_num_output_train_data(train_data))

fann_set_training_algorithm(ann, training_algorithm)
fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_LINEAR)
fann_set_train_error_function(ann, FANN_ERRORFUNC_LINEAR)

if multi = 0 then
	steepness = 1
	fann_set_cascade_activation_steepnesses(ann, @steepness, 1)
	activation = FANN_SIGMOID_SYMMETRIC
	fann_set_cascade_activation_functions(ann, @activation, 1)
	fann_set_cascade_num_candidate_groups(ann, 8)
end if

if training_algorithm = FANN_TRAIN_QUICKPROP then
	fann_set_learning_rate(ann, 0.35)
	fann_randomize_weights(ann, -2.0, 2.0)
end if

fann_set_bit_fail_limit(ann, 0.9)
fann_set_train_stop_function(ann, FANN_STOPFUNC_BIT)
fann_print_parameters(ann)

fann_save(ann, "cascade_train2.net")

printf(!"Training network.\n")

fann_cascadetrain_on_data(ann, train_data, max_neurons, neurons_between_reports, desired_error)

fann_print_connections(ann)

mse_train = fann_test_data(ann, train_data)
bit_fail_train = fann_get_bit_fail(ann)
mse_test = fann_test_data(ann, test_data)
bit_fail_test = fann_get_bit_fail(ann)

printf(!"\nTrain error: %f, Train bit-fail: %d, Test error: %f, Test bit-fail: %d\n\n", _
       cdbl(mse_train), bit_fail_train, cdbl(mse_test), bit_fail_test)

for i = 0 to fann_length_train_data(train_data) - 1
	dim as fann_type ptr invec = fann_get_train_input(train_data, i)
	dim as fann_type ptr outp = fann_get_train_output(train_data, i)
	output_ = fann_run(ann, invec)
	if ((outp[0] >= 0) andalso (output_[0] <= 0)) orelse _
	   ((outp[0] <= 0) andalso (output_[0] >= 0)) then
		printf(!"ERROR: %f does not match %f\n", cdbl(outp[0]), cdbl(output_[0]))
	end if
next

printf(!"Saving network.\n")

fann_save(ann, "cascade_train.net")

printf(!"Cleaning up.\n")
fann_destroy_train(train_data)
fann_destroy_train(test_data)
fann_destroy(ann)
