# FANN for FreeBASIC

FreeBASIC bindings and prebuilt static libraries for **FANN** (Fast Artificial
Neural Network Library) -- https://github.com/libfann/fann

- Variant: **floatfann** (`fann_type` = `SINGLE`)
- Calling convention: plain **cdecl** (no DLL, no stdcall)
- Built with `-DDISABLE_PARALLEL_FANN` (no OpenMP dependency -- clean static linking)
- License of FANN itself: LGPL 2.1 (see LICENSE.md)

## Contents

```
fann.bi                     FreeBASIC header (all ~175 exported functions)
lib/win32/libfloatfann.a    Windows 32-bit static library (for fbc32.exe)
lib/linux64/libfloatfann.a  Linux x86_64 static library   (for 64-bit fbc)
examples/                   All official FANN examples ported to FreeBASIC
datasets/                   Datasets used by the examples
```

## Examples (ported from FANN's examples/ directory)

All programs were compiled with fbc and run successfully -- results match
the C originals. Run them from inside the `examples/` directory (they use
relative paths like `../datasets/...`).

| Program              | Demonstrates                                            |
|----------------------|---------------------------------------------------------|
| simple_train.bas     | Minimal training on xor.data, saves xor_float.net       |
| simple_test.bas      | Minimal loading + running a saved network               |
| xor_train.bas        | RPROP, bit-fail stopping, **FB training callback**, fixed-point export |
| xor_test.bas         | Load net, print connections/parameters, test all samples|
| xor_inmemory.bas     | Bonus: build the training set in memory, no data file   |
| steepness_train.bas  | Custom epoch loop with fann_train_epoch + steepness ramp|
| cascade_train.bas    | Cascade-correlation on parity-8 (network grows itself)  |
| mushroom.bas         | 125-input classifier, large dataset (edible/poisonous)  |
| robot.bas            | Incremental training + momentum on robot sensor data    |
| robot_adam.bas       | Same task with the Adam optimizer                       |
| momentums.bas        | Sweeps momentum 0.0-0.6 and compares train/test MSE     |
| scaling_train.bas    | Built-in input/output scaling stored in the net file    |
| scaling_test.bas     | fann_scale_input / fann_descale_output at run time      |

Not ported: parallel_train.c (the libraries are built without the OpenMP
parallel functions) and the tests/ directory (C++ googletest unit tests,
not applicable to FB).

Typical run order: `xor_train` then `xor_test`; `scaling_train` then
`scaling_test`. Note: `inp` is a reserved keyword in FreeBASIC (port I/O),
which is why the ports use `invec` for input vectors.

## Building your programs

The header already contains `#inclib "floatfann"`, so you only need to tell
fbc where the library lives with `-p`:

**Windows 32-bit:**
```
fbc32 myprog.bas -p path\to\lib\win32
```

**Linux 64-bit:**
```
fbc myprog.bas -p path/to/lib/linux64
```

Or simply copy the matching `libfloatfann.a` into your FreeBASIC `lib`
directory (e.g. `FreeBASIC\lib\win32\` on Windows,
`/usr/local/lib/freebasic/linux-x86_64/` on Linux) and forget about `-p`.

## Quick example

```freebasic
#include "fann.bi"

dim as fann ptr ann = fann_create_standard(3, 2ul, 3ul, 1ul)
fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC)
fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC)

' ... train with fann_train_on_data() or fann_train_on_file() ...

dim as fann_type inputs(0 to 1) = { 1, -1 }
dim as fann_type ptr result = fann_run(ann, @inputs(0))
print result[0]

fann_destroy(ann)
```

The XOR example was compiled and run successfully on Linux 64-bit:
it converges in ~34 epochs and outputs the correct XOR values.

## Notes and gotchas

- **Varargs creators:** `fann_create_standard(num_layers, ...)` takes the layer
  sizes as C `unsigned int` varargs. In FreeBASIC pass them with the `ul`
  suffix, e.g. `fann_create_standard(3, 2ul, 3ul, 1ul)`, or use the safer
  `fann_create_standard_array()` with a `ulong` array.
- **fann_type is SINGLE.** All input/output vectors are `single` arrays; pass
  pointers with `@myarray(0)`.
- **Training data files** use FANN's plain text format (first line:
  `num_samples num_inputs num_outputs`, then alternating input/output lines).
  `fann_create_train_array()` lets you build datasets in memory instead.
- **Callbacks:** training callbacks must be declared `cdecl` returning `long`;
  return `-1` to abort training. See `fann_callback_type` in fann.bi.
- The fixed-point functions (`fann_get_decimal_point`, `fann_save_to_fixed`,
  ...) exist but are only meaningful for fixedfann builds.
- Both libraries export the same 222 symbols, so code is 100% portable
  between the two targets.

## How the libraries were built

```
# Linux 64-bit
gcc -O2 -DDISABLE_PARALLEL_FANN -Iinclude -c floatfann.c
ar rcs libfloatfann.a floatfann.o

# Windows 32-bit (MinGW cross)
i686-w64-mingw32-gcc -O2 -DDISABLE_PARALLEL_FANN -D__USE_MINGW_ANSI_STDIO=0 \
    -Iinclude -c floatfann.c
i686-w64-mingw32-ar rcs libfloatfann.a floatfann.o
```

(from FANN git master, August 2026)

If you ever need the **double** variant, compile `doublefann.c` the same way
and change `type fann_type as single` to `as double` in fann.bi.
