'' simple_test.bas -- port of FANN examples/simple_test.c
'' Minimal execution example: load a saved net and run one input.

#include "../fann.bi"

dim as fann_type ptr calc_out
dim as fann_type input_(0 to 1)

dim as fann ptr ann = fann_create_from_file("xor_float.net")

input_(0) = -1
input_(1) = 1
calc_out = fann_run(ann, @input_(0))

printf(!"xor test (%f,%f) -> %f\n", cdbl(input_(0)), cdbl(input_(1)), cdbl(calc_out[0]))

fann_destroy(ann)
