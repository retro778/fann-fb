'' steepness_train.bas -- port of FANN examples/steepness_train.c
'' Trains XOR while gradually increasing activation steepness, then
'' switches to threshold activation for exact -1/1 outputs.

#include "../fann.bi"

sub train_on_steepness_file( _
		byval ann as fann ptr, byref filename as string, _
		byval max_epochs as ulong, byval epochs_between_reports as ulong, _
		byval desired_error as single, byval steepness_start as single, _
		byval steepness_step as single, byval steepness_end as single)

	dim as single error_
	dim as ulong i

	dim as fann_train_data ptr data_ = fann_read_train_from_file(filename)

	if epochs_between_reports then
		printf(!"Max epochs %8d. Desired error: %.10f\n", max_epochs, cdbl(desired_error))
	end if

	fann_set_activation_steepness_hidden(ann, steepness_start)
	fann_set_activation_steepness_output(ann, steepness_start)

	for i = 1 to max_epochs
		'' train one epoch
		error_ = fann_train_epoch(ann, data_)

		'' print current output
		if epochs_between_reports andalso _
		   ((i mod epochs_between_reports = 0) orelse (i = max_epochs) orelse _
		    (i = 1) orelse (error_ < desired_error)) then
			printf(!"Epochs     %8d. Current error: %.10f\n", i, cdbl(error_))
		end if

		if error_ < desired_error then
			steepness_start += steepness_step
			if steepness_start <= steepness_end then
				printf(!"Steepness: %f\n", cdbl(steepness_start))
				fann_set_activation_steepness_hidden(ann, steepness_start)
				fann_set_activation_steepness_output(ann, steepness_start)
			else
				exit for
			end if
		end if
	next

	fann_destroy_train(data_)
end sub

const num_input = 2ul
const num_output = 1ul
const num_layers = 3ul
const num_neurons_hidden = 3ul
const desired_error = 0.001!
const max_epochs = 500000ul
const epochs_between_reports = 1000ul
dim as ulong i
dim as fann_type ptr calc_out
dim as fann_train_data ptr data_

dim as fann ptr ann = fann_create_standard(num_layers, num_input, num_neurons_hidden, num_output)

data_ = fann_read_train_from_file("xor.data")

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC)

fann_set_training_algorithm(ann, FANN_TRAIN_QUICKPROP)

train_on_steepness_file(ann, "xor.data", max_epochs, _
                        epochs_between_reports, desired_error, 1.0, 0.1, 20.0)

fann_set_activation_function_hidden(ann, FANN_THRESHOLD_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_THRESHOLD_SYMMETRIC)

for i = 0 to fann_length_train_data(data_) - 1
	dim as fann_type ptr invec = fann_get_train_input(data_, i)
	dim as fann_type ptr outp = fann_get_train_output(data_, i)
	calc_out = fann_run(ann, invec)
	printf(!"XOR test (%f, %f) -> %f, should be %f, difference=%f\n", _
	       cdbl(invec[0]), cdbl(invec[1]), cdbl(calc_out[0]), cdbl(outp[0]), _
	       cdbl(abs(calc_out[0] - outp[0])))
next

fann_save(ann, "xor_float.net")

fann_destroy(ann)
fann_destroy_train(data_)
