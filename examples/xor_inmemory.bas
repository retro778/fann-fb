'' xor_train.bas -- classic XOR example using FANN from FreeBASIC
''
'' Build (Linux 64-bit):
''   fbc xor_train.bas -p ../lib/linux64
'' Build (Windows 32-bit):
''   fbc32 xor_train.bas -p ..\lib\win32

#include "../fann.bi"

'' XOR training data built in memory (no data file needed)
'' 4 samples, 2 inputs, 1 output -- flat arrays for fann_create_train_array
dim as fann_type inputs(0 to 7)  = { -1, -1,   -1, 1,   1, -1,   1, 1 }
dim as fann_type outputs(0 to 3) = { -1,        1,       1,      -1 }

dim as fann_train_data ptr data_ = fann_create_train_array(4, 2, @inputs(0), 1, @outputs(0))
if data_ = 0 then
	print "Failed to create training data!"
	end 1
end if

'' 3-layer network: 2 inputs, 3 hidden, 1 output
dim as fann ptr ann = fann_create_standard(3, 2ul, 3ul, 1ul)
if ann = 0 then
	print "Failed to create network!"
	end 1
end if

fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_training_algorithm(ann, FANN_TRAIN_RPROP)
fann_init_weights(ann, data_)

print "Training XOR network..."
fann_train_on_data(ann, data_, 5000, 500, 0.0001)

print
print "Testing:"
dim as fann_type testin(0 to 1)
dim as fann_type ptr result

for i as integer = 0 to 3
	testin(0) = inputs(i * 2)
	testin(1) = inputs(i * 2 + 1)
	result = fann_run(ann, @testin(0))
	print "XOR("; testin(0); ","; testin(1); ") = "; result[0]; _
	      "   (expected "; outputs(i); ")"
next

print
print "Final MSE: "; fann_get_MSE(ann)

'' Save the trained network -- can be reloaded with fann_create_from_file
fann_save(ann, "xor_trained.net")
print "Network saved to xor_trained.net"

fann_destroy_train(data_)
fann_destroy(ann)
