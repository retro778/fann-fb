'' xor_train.bas -- port of FANN examples/xor_train.c
'' Trains XOR with RPROP, bit-fail stop function, and a custom
'' training callback, then saves float and fixed-point networks.

#include "../fann.bi"

'' Training callback: called every epochs_between_reports epochs.
'' Return -1 to stop training.
function test_callback cdecl( _
		byval ann as fann ptr, byval train as fann_train_data ptr, _
		byval max_epochs as ulong, byval epochs_between_reports as ulong, _
		byval desired_error as single, byval epochs as ulong) as long
	printf(!"Epochs     %8d. MSE: %.5f. Desired-MSE: %.5f\n", _
	       epochs, cdbl(fann_get_MSE(ann)), cdbl(desired_error))
	return 0
end function

dim as fann_type ptr calc_out
const num_input = 2ul
const num_output = 1ul
const num_layers = 3ul
const num_neurons_hidden = 3ul
const desired_error = 0.0!
const max_epochs = 1000ul
const epochs_between_reports = 10ul
dim as fann ptr ann
dim as fann_train_data ptr data_
dim as ulong i, decimal_point

printf(!"Creating network.\n")
ann = fann_create_standard(num_layers, num_input, num_neurons_hidden, num_output)

data_ = fann_read_train_from_file("xor.data")

fann_set_activation_steepness_hidden(ann, 1)
fann_set_activation_steepness_output(ann, 1)

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC)

fann_set_train_stop_function(ann, FANN_STOPFUNC_BIT)
fann_set_bit_fail_limit(ann, 0.01)

fann_set_training_algorithm(ann, FANN_TRAIN_RPROP)

fann_init_weights(ann, data_)

'' the C original defines test_callback; hook it up to demonstrate
'' FreeBASIC callbacks (comment this out for FANN's default reports)
fann_set_callback(ann, @test_callback)

printf(!"Training network.\n")
fann_train_on_data(ann, data_, max_epochs, epochs_between_reports, desired_error)

printf(!"Testing network. %f\n", cdbl(fann_test_data(ann, data_)))

for i = 0 to fann_length_train_data(data_) - 1
	dim as fann_type ptr invec = fann_get_train_input(data_, i)
	dim as fann_type ptr outp = fann_get_train_output(data_, i)
	calc_out = fann_run(ann, invec)
	printf(!"XOR test (%f,%f) -> %f, should be %f, difference=%f\n", _
	       cdbl(invec[0]), cdbl(invec[1]), cdbl(calc_out[0]), cdbl(outp[0]), _
	       cdbl(abs(calc_out[0] - outp[0])))
next

printf(!"Saving network.\n")

fann_save(ann, "xor_float.net")

decimal_point = fann_save_to_fixed(ann, "xor_fixed.net")
fann_save_train_to_fixed(data_, "xor_fixed.data", decimal_point)

printf(!"Cleaning up.\n")
fann_destroy_train(data_)
fann_destroy(ann)
