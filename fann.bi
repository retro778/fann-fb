''
''  fann.bi -- FreeBASIC bindings for FANN (Fast Artificial Neural Network Library)
''
''  Library: https://github.com/libfann/fann  (LGPL 2.1)
''  Variant: floatfann  (fann_type = SINGLE)
''
''  Works with:
''    - fbc 32-bit on Windows  (link against win32/libfloatfann.a)
''    - fbc 64-bit on Linux    (link against linux64/libfloatfann.a)
''
''  The libraries were built as static archives with plain cdecl calling
''  convention (no DLL, no OpenMP / parallel functions).
''
''  Usage:
''      #include "fann.bi"
''      ...
''      fbc yourprog.bas -p path\to\libdir
''

#pragma once

#include once "crt/stdio.bi"   '' for FILE ptr (fann_set_error_log)

#inclib "floatfann"

extern "C"

'' ---------------------------------------------------------------------------
'' Basic types
'' ---------------------------------------------------------------------------

'' fann_type is float in the floatfann build
type fann_type as single

'' Opaque structures -- only ever used through pointers
type fann as fann_
type fann_train_data as fann_train_data_
type fann_error as fann_error_

'' ---------------------------------------------------------------------------
'' Enums
'' ---------------------------------------------------------------------------

enum fann_train_enum
	FANN_TRAIN_INCREMENTAL = 0
	FANN_TRAIN_BATCH
	FANN_TRAIN_RPROP
	FANN_TRAIN_QUICKPROP
	FANN_TRAIN_SARPROP
	FANN_TRAIN_ADAM
end enum

enum fann_activationfunc_enum
	FANN_LINEAR = 0
	FANN_THRESHOLD
	FANN_THRESHOLD_SYMMETRIC
	FANN_SIGMOID
	FANN_SIGMOID_STEPWISE
	FANN_SIGMOID_SYMMETRIC
	FANN_SIGMOID_SYMMETRIC_STEPWISE
	FANN_GAUSSIAN
	FANN_GAUSSIAN_SYMMETRIC
	FANN_GAUSSIAN_STEPWISE
	FANN_ELLIOT
	FANN_ELLIOT_SYMMETRIC
	FANN_LINEAR_PIECE
	FANN_LINEAR_PIECE_SYMMETRIC
	FANN_SIN_SYMMETRIC
	FANN_COS_SYMMETRIC
	FANN_SIN
	FANN_COS
	FANN_LINEAR_PIECE_RECT
	FANN_LINEAR_PIECE_RECT_LEAKY
end enum

enum fann_errorfunc_enum
	FANN_ERRORFUNC_LINEAR = 0
	FANN_ERRORFUNC_TANH
end enum

enum fann_stopfunc_enum
	FANN_STOPFUNC_MSE = 0
	FANN_STOPFUNC_BIT
end enum

enum fann_nettype_enum
	FANN_NETTYPE_LAYER = 0
	FANN_NETTYPE_SHORTCUT
end enum

enum fann_errno_enum
	FANN_E_NO_ERROR = 0
	FANN_E_CANT_OPEN_CONFIG_R
	FANN_E_CANT_OPEN_CONFIG_W
	FANN_E_WRONG_CONFIG_VERSION
	FANN_E_CANT_READ_CONFIG
	FANN_E_CANT_READ_NEURON
	FANN_E_CANT_READ_CONNECTIONS
	FANN_E_WRONG_NUM_CONNECTIONS
	FANN_E_CANT_OPEN_TD_W
	FANN_E_CANT_OPEN_TD_R
	FANN_E_CANT_READ_TD
	FANN_E_CANT_ALLOCATE_MEM
	FANN_E_CANT_TRAIN_ACTIVATION
	FANN_E_CANT_USE_ACTIVATION
	FANN_E_TRAIN_DATA_MISMATCH
	FANN_E_CANT_USE_TRAIN_ALG
	FANN_E_TRAIN_DATA_SUBSET
	FANN_E_INDEX_OUT_OF_BOUND
	FANN_E_SCALE_NOT_PRESENT
	FANN_E_INPUT_NO_MATCH
	FANN_E_OUTPUT_NO_MATCH
	FANN_E_WRONG_PARAMETERS_FOR_CREATE
end enum

'' ---------------------------------------------------------------------------
'' Structures
'' ---------------------------------------------------------------------------

type fann_connection
	from_neuron as ulong
	to_neuron as ulong
	weight as fann_type
end type

'' Training callback:
'' return -1 from the callback to stop training immediately
type fann_callback_type as function cdecl( _
	byval ann as fann ptr, _
	byval train as fann_train_data ptr, _
	byval max_epochs as ulong, _
	byval epochs_between_reports as ulong, _
	byval desired_error as single, _
	byval epochs as ulong) as long

'' User function for fann_create_train_from_callback
type fann_train_fill_callback as sub cdecl( _
	byval num as ulong, _
	byval num_input as ulong, _
	byval num_output as ulong, _
	byval input as fann_type ptr, _
	byval output as fann_type ptr)

'' ---------------------------------------------------------------------------
'' Error handling (fann_error.h)
'' ---------------------------------------------------------------------------

extern fann_default_error_log as FILE ptr

declare sub fann_set_error_log(byval errdat as fann_error ptr, byval log_file as FILE ptr)
declare function fann_get_errno(byval errdat as fann_error ptr) as fann_errno_enum
declare sub fann_reset_errno(byval errdat as fann_error ptr)
declare sub fann_reset_errstr(byval errdat as fann_error ptr)
declare function fann_get_errstr(byval errdat as fann_error ptr) as zstring ptr
declare sub fann_print_error(byval errdat as fann_error ptr)

'' ---------------------------------------------------------------------------
'' Creation, destruction, execution (fann.h)
'' ---------------------------------------------------------------------------

declare function fann_create_standard(byval num_layers as ulong, ...) as fann ptr
declare function fann_create_standard_array(byval num_layers as ulong, byval layers as const ulong ptr) as fann ptr
declare function fann_create_sparse(byval connection_rate as single, byval num_layers as ulong, ...) as fann ptr
declare function fann_create_sparse_array(byval connection_rate as single, byval num_layers as ulong, byval layers as const ulong ptr) as fann ptr
declare function fann_create_shortcut(byval num_layers as ulong, ...) as fann ptr
declare function fann_create_shortcut_array(byval num_layers as ulong, byval layers as const ulong ptr) as fann ptr
declare sub fann_destroy(byval ann as fann ptr)
declare function fann_copy(byval ann as fann ptr) as fann ptr
declare function fann_run(byval ann as fann ptr, byval input as fann_type ptr) as fann_type ptr
declare sub fann_randomize_weights(byval ann as fann ptr, byval min_weight as fann_type, byval max_weight as fann_type)
declare sub fann_init_weights(byval ann as fann ptr, byval train_data as fann_train_data ptr)
declare sub fann_print_connections(byval ann as fann ptr)
declare sub fann_print_parameters(byval ann as fann ptr)

declare function fann_get_num_input(byval ann as fann ptr) as ulong
declare function fann_get_num_output(byval ann as fann ptr) as ulong
declare function fann_get_total_neurons(byval ann as fann ptr) as ulong
declare function fann_get_total_connections(byval ann as fann ptr) as ulong
declare function fann_get_network_type(byval ann as fann ptr) as fann_nettype_enum
declare function fann_get_connection_rate(byval ann as fann ptr) as single
declare function fann_get_num_layers(byval ann as fann ptr) as ulong
declare sub fann_get_layer_array(byval ann as fann ptr, byval layers as ulong ptr)
declare sub fann_get_bias_array(byval ann as fann ptr, byval bias as ulong ptr)
declare sub fann_get_connection_array(byval ann as fann ptr, byval connections as fann_connection ptr)
declare sub fann_set_weight_array(byval ann as fann ptr, byval connections as fann_connection ptr, byval num_connections as ulong)
declare sub fann_set_weight(byval ann as fann ptr, byval from_neuron as ulong, byval to_neuron as ulong, byval weight as fann_type)
declare sub fann_get_weights(byval ann as fann ptr, byval weights as fann_type ptr)
declare sub fann_set_weights(byval ann as fann ptr, byval weights as fann_type ptr)
declare sub fann_set_user_data(byval ann as fann ptr, byval user_data as any ptr)
declare function fann_get_user_data(byval ann as fann ptr) as any ptr
declare sub fann_disable_seed_rand()
declare sub fann_enable_seed_rand()

'' ---------------------------------------------------------------------------
'' File input/output (fann_io.h)
'' ---------------------------------------------------------------------------

declare function fann_create_from_file(byval configuration_file as const zstring ptr) as fann ptr
declare function fann_save(byval ann as fann ptr, byval configuration_file as const zstring ptr) as long
declare function fann_save_to_fixed(byval ann as fann ptr, byval configuration_file as const zstring ptr) as long

'' ---------------------------------------------------------------------------
'' Training (fann_train.h)
'' ---------------------------------------------------------------------------

declare sub fann_train(byval ann as fann ptr, byval input as fann_type ptr, byval desired_output as fann_type ptr)
declare function fann_test(byval ann as fann ptr, byval input as fann_type ptr, byval desired_output as fann_type ptr) as fann_type ptr
declare function fann_get_MSE(byval ann as fann ptr) as single
declare function fann_get_bit_fail(byval ann as fann ptr) as ulong
declare sub fann_reset_MSE(byval ann as fann ptr)
declare sub fann_train_on_data(byval ann as fann ptr, byval data_ as fann_train_data ptr, byval max_epochs as ulong, byval epochs_between_reports as ulong, byval desired_error as single)
declare sub fann_train_on_file(byval ann as fann ptr, byval filename as const zstring ptr, byval max_epochs as ulong, byval epochs_between_reports as ulong, byval desired_error as single)
declare function fann_train_epoch(byval ann as fann ptr, byval data_ as fann_train_data ptr) as single
declare function fann_test_data(byval ann as fann ptr, byval data_ as fann_train_data ptr) as single

'' Training data handling
declare function fann_read_train_from_file(byval filename as const zstring ptr) as fann_train_data ptr
declare function fann_create_train(byval num_data as ulong, byval num_input as ulong, byval num_output as ulong) as fann_train_data ptr
declare function fann_create_train_pointer_array(byval num_data as ulong, byval num_input as ulong, byval input as fann_type ptr ptr, byval num_output as ulong, byval output as fann_type ptr ptr) as fann_train_data ptr
declare function fann_create_train_array(byval num_data as ulong, byval num_input as ulong, byval input as fann_type ptr, byval num_output as ulong, byval output as fann_type ptr) as fann_train_data ptr
declare function fann_create_train_from_callback(byval num_data as ulong, byval num_input as ulong, byval num_output as ulong, byval user_function as fann_train_fill_callback) as fann_train_data ptr
declare sub fann_destroy_train(byval train_data as fann_train_data ptr)
declare function fann_get_train_input(byval data_ as fann_train_data ptr, byval position as ulong) as fann_type ptr
declare function fann_get_train_output(byval data_ as fann_train_data ptr, byval position as ulong) as fann_type ptr
declare sub fann_shuffle_train_data(byval train_data as fann_train_data ptr)
declare function fann_get_min_train_input(byval train_data as fann_train_data ptr) as fann_type
declare function fann_get_max_train_input(byval train_data as fann_train_data ptr) as fann_type
declare function fann_get_min_train_output(byval train_data as fann_train_data ptr) as fann_type
declare function fann_get_max_train_output(byval train_data as fann_train_data ptr) as fann_type

'' Scaling
declare sub fann_scale_train(byval ann as fann ptr, byval data_ as fann_train_data ptr)
declare sub fann_descale_train(byval ann as fann ptr, byval data_ as fann_train_data ptr)
declare function fann_set_input_scaling_params(byval ann as fann ptr, byval data_ as const fann_train_data ptr, byval new_input_min as single, byval new_input_max as single) as long
declare function fann_set_output_scaling_params(byval ann as fann ptr, byval data_ as const fann_train_data ptr, byval new_output_min as single, byval new_output_max as single) as long
declare function fann_set_scaling_params(byval ann as fann ptr, byval data_ as const fann_train_data ptr, byval new_input_min as single, byval new_input_max as single, byval new_output_min as single, byval new_output_max as single) as long
declare function fann_clear_scaling_params(byval ann as fann ptr) as long
declare sub fann_scale_input(byval ann as fann ptr, byval input_vector as fann_type ptr)
declare sub fann_scale_output(byval ann as fann ptr, byval output_vector as fann_type ptr)
declare sub fann_descale_input(byval ann as fann ptr, byval input_vector as fann_type ptr)
declare sub fann_descale_output(byval ann as fann ptr, byval output_vector as fann_type ptr)
declare sub fann_scale_input_train_data(byval train_data as fann_train_data ptr, byval new_min as fann_type, byval new_max as fann_type)
declare sub fann_scale_output_train_data(byval train_data as fann_train_data ptr, byval new_min as fann_type, byval new_max as fann_type)
declare sub fann_scale_train_data(byval train_data as fann_train_data ptr, byval new_min as fann_type, byval new_max as fann_type)

declare function fann_merge_train_data(byval data1 as fann_train_data ptr, byval data2 as fann_train_data ptr) as fann_train_data ptr
declare function fann_duplicate_train_data(byval data_ as fann_train_data ptr) as fann_train_data ptr
declare function fann_subset_train_data(byval data_ as fann_train_data ptr, byval pos_ as ulong, byval length_ as ulong) as fann_train_data ptr
declare function fann_length_train_data(byval data_ as fann_train_data ptr) as ulong
declare function fann_num_input_train_data(byval data_ as fann_train_data ptr) as ulong
declare function fann_num_output_train_data(byval data_ as fann_train_data ptr) as ulong
declare function fann_save_train(byval data_ as fann_train_data ptr, byval filename as const zstring ptr) as long
declare function fann_save_train_to_fixed(byval data_ as fann_train_data ptr, byval filename as const zstring ptr, byval decimal_point as ulong) as long

'' Training parameters
declare function fann_get_training_algorithm(byval ann as fann ptr) as fann_train_enum
declare sub fann_set_training_algorithm(byval ann as fann ptr, byval training_algorithm as fann_train_enum)
declare function fann_get_learning_rate(byval ann as fann ptr) as single
declare sub fann_set_learning_rate(byval ann as fann ptr, byval learning_rate as single)
declare function fann_get_learning_momentum(byval ann as fann ptr) as single
declare sub fann_set_learning_momentum(byval ann as fann ptr, byval learning_momentum as single)
declare function fann_get_adam_beta1(byval ann as fann ptr) as single
declare sub fann_set_adam_beta1(byval ann as fann ptr, byval adam_beta1 as single)
declare function fann_get_adam_beta2(byval ann as fann ptr) as single
declare sub fann_set_adam_beta2(byval ann as fann ptr, byval adam_beta2 as single)
declare function fann_get_adam_epsilon(byval ann as fann ptr) as single
declare sub fann_set_adam_epsilon(byval ann as fann ptr, byval adam_epsilon as single)

declare function fann_get_activation_function(byval ann as fann ptr, byval layer as long, byval neuron as long) as fann_activationfunc_enum
declare sub fann_set_activation_function(byval ann as fann ptr, byval activation_function as fann_activationfunc_enum, byval layer as long, byval neuron as long)
declare sub fann_set_activation_function_layer(byval ann as fann ptr, byval activation_function as fann_activationfunc_enum, byval layer as long)
declare sub fann_set_activation_function_hidden(byval ann as fann ptr, byval activation_function as fann_activationfunc_enum)
declare sub fann_set_activation_function_output(byval ann as fann ptr, byval activation_function as fann_activationfunc_enum)
declare function fann_get_activation_steepness(byval ann as fann ptr, byval layer as long, byval neuron as long) as fann_type
declare sub fann_set_activation_steepness(byval ann as fann ptr, byval steepness as fann_type, byval layer as long, byval neuron as long)
declare sub fann_set_activation_steepness_layer(byval ann as fann ptr, byval steepness as fann_type, byval layer as long)
declare sub fann_set_activation_steepness_hidden(byval ann as fann ptr, byval steepness as fann_type)
declare sub fann_set_activation_steepness_output(byval ann as fann ptr, byval steepness as fann_type)

declare function fann_get_train_error_function(byval ann as fann ptr) as fann_errorfunc_enum
declare sub fann_set_train_error_function(byval ann as fann ptr, byval train_error_function as fann_errorfunc_enum)
declare function fann_get_train_stop_function(byval ann as fann ptr) as fann_stopfunc_enum
declare sub fann_set_train_stop_function(byval ann as fann ptr, byval train_stop_function as fann_stopfunc_enum)
declare function fann_get_bit_fail_limit(byval ann as fann ptr) as fann_type
declare sub fann_set_bit_fail_limit(byval ann as fann ptr, byval bit_fail_limit as fann_type)
declare sub fann_set_callback(byval ann as fann ptr, byval callback as fann_callback_type)

declare function fann_get_quickprop_decay(byval ann as fann ptr) as single
declare sub fann_set_quickprop_decay(byval ann as fann ptr, byval quickprop_decay as single)
declare function fann_get_quickprop_mu(byval ann as fann ptr) as single
declare sub fann_set_quickprop_mu(byval ann as fann ptr, byval quickprop_mu as single)
declare function fann_get_rprop_increase_factor(byval ann as fann ptr) as single
declare sub fann_set_rprop_increase_factor(byval ann as fann ptr, byval rprop_increase_factor as single)
declare function fann_get_rprop_decrease_factor(byval ann as fann ptr) as single
declare sub fann_set_rprop_decrease_factor(byval ann as fann ptr, byval rprop_decrease_factor as single)
declare function fann_get_rprop_delta_min(byval ann as fann ptr) as single
declare sub fann_set_rprop_delta_min(byval ann as fann ptr, byval rprop_delta_min as single)
declare function fann_get_rprop_delta_max(byval ann as fann ptr) as single
declare sub fann_set_rprop_delta_max(byval ann as fann ptr, byval rprop_delta_max as single)
declare function fann_get_rprop_delta_zero(byval ann as fann ptr) as single
declare sub fann_set_rprop_delta_zero(byval ann as fann ptr, byval rprop_delta_zero as single)
declare function fann_get_sarprop_weight_decay_shift(byval ann as fann ptr) as single
declare sub fann_set_sarprop_weight_decay_shift(byval ann as fann ptr, byval sarprop_weight_decay_shift as single)
declare function fann_get_sarprop_step_error_threshold_factor(byval ann as fann ptr) as single
declare sub fann_set_sarprop_step_error_threshold_factor(byval ann as fann ptr, byval sarprop_step_error_threshold_factor as single)
declare function fann_get_sarprop_step_error_shift(byval ann as fann ptr) as single
declare sub fann_set_sarprop_step_error_shift(byval ann as fann ptr, byval sarprop_step_error_shift as single)
declare function fann_get_sarprop_temperature(byval ann as fann ptr) as single
declare sub fann_set_sarprop_temperature(byval ann as fann ptr, byval sarprop_temperature as single)

'' Fixed point (only meaningful for fixedfann builds, but exported anyway)
declare function fann_get_decimal_point(byval ann as fann ptr) as ulong
declare function fann_get_multiplier(byval ann as fann ptr) as ulong

'' ---------------------------------------------------------------------------
'' Cascade training (fann_cascade.h)
'' ---------------------------------------------------------------------------

declare sub fann_cascadetrain_on_data(byval ann as fann ptr, byval data_ as fann_train_data ptr, byval max_neurons as ulong, byval neurons_between_reports as ulong, byval desired_error as single)
declare sub fann_cascadetrain_on_file(byval ann as fann ptr, byval filename as const zstring ptr, byval max_neurons as ulong, byval neurons_between_reports as ulong, byval desired_error as single)
declare function fann_get_cascade_output_change_fraction(byval ann as fann ptr) as single
declare sub fann_set_cascade_output_change_fraction(byval ann as fann ptr, byval cascade_output_change_fraction as single)
declare function fann_get_cascade_output_stagnation_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_output_stagnation_epochs(byval ann as fann ptr, byval cascade_output_stagnation_epochs as ulong)
declare function fann_get_cascade_candidate_change_fraction(byval ann as fann ptr) as single
declare sub fann_set_cascade_candidate_change_fraction(byval ann as fann ptr, byval cascade_candidate_change_fraction as single)
declare function fann_get_cascade_candidate_stagnation_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_candidate_stagnation_epochs(byval ann as fann ptr, byval cascade_candidate_stagnation_epochs as ulong)
declare function fann_get_cascade_weight_multiplier(byval ann as fann ptr) as fann_type
declare sub fann_set_cascade_weight_multiplier(byval ann as fann ptr, byval cascade_weight_multiplier as fann_type)
declare function fann_get_cascade_candidate_limit(byval ann as fann ptr) as fann_type
declare sub fann_set_cascade_candidate_limit(byval ann as fann ptr, byval cascade_candidate_limit as fann_type)
declare function fann_get_cascade_max_out_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_max_out_epochs(byval ann as fann ptr, byval cascade_max_out_epochs as ulong)
declare function fann_get_cascade_min_out_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_min_out_epochs(byval ann as fann ptr, byval cascade_min_out_epochs as ulong)
declare function fann_get_cascade_max_cand_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_max_cand_epochs(byval ann as fann ptr, byval cascade_max_cand_epochs as ulong)
declare function fann_get_cascade_min_cand_epochs(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_min_cand_epochs(byval ann as fann ptr, byval cascade_min_cand_epochs as ulong)
declare function fann_get_cascade_num_candidates(byval ann as fann ptr) as ulong
declare function fann_get_cascade_activation_functions_count(byval ann as fann ptr) as ulong
declare function fann_get_cascade_activation_functions(byval ann as fann ptr) as fann_activationfunc_enum ptr
declare sub fann_set_cascade_activation_functions(byval ann as fann ptr, byval cascade_activation_functions as fann_activationfunc_enum ptr, byval cascade_activation_functions_count as ulong)
declare function fann_get_cascade_activation_steepnesses_count(byval ann as fann ptr) as ulong
declare function fann_get_cascade_activation_steepnesses(byval ann as fann ptr) as fann_type ptr
declare sub fann_set_cascade_activation_steepnesses(byval ann as fann ptr, byval cascade_activation_steepnesses as fann_type ptr, byval cascade_activation_steepnesses_count as ulong)
declare function fann_get_cascade_num_candidate_groups(byval ann as fann ptr) as ulong
declare sub fann_set_cascade_num_candidate_groups(byval ann as fann ptr, byval cascade_num_candidate_groups as ulong)

end extern
