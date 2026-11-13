'' scaling_test.bas -- port of FANN examples/scaling_test.c
'' Loads scaling.net and runs it on the raw dataset, scaling inputs
'' and descaling outputs on the fly.

#include "../fann.bi"

dim as fann_type ptr calc_out
dim as ulong i
dim as fann ptr ann
dim as fann_train_data ptr data_

printf(!"Creating network.\n")
ann = fann_create_from_file("scaling.net")
if ann = 0 then
	printf(!"Error creating ann --- ABORTING.\n")
	end 0
end if

fann_print_connections(ann)
fann_print_parameters(ann)

printf(!"Testing network.\n")
data_ = fann_read_train_from_file("../datasets/scaling.data")

for i = 0 to fann_length_train_data(data_) - 1
	dim as fann_type ptr invec = fann_get_train_input(data_, i)
	dim as fann_type ptr outp = fann_get_train_output(data_, i)
	fann_reset_MSE(ann)
	fann_scale_input(ann, invec)
	calc_out = fann_run(ann, invec)
	fann_descale_output(ann, calc_out)
	printf(!"Result %f original %f error %f\n", _
	       cdbl(calc_out[0]), cdbl(outp[0]), _
	       cdbl(abs(calc_out[0] - outp[0])))
next

printf(!"Cleaning up.\n")
fann_destroy_train(data_)
fann_destroy(ann)
