# Like Compiler Test Suite

This contains all our tests for each phase, both positive and negative cases, grouped by the phase in which they were written.

Each phase directory has a corresponding test documentation file named `testDescriptionsPhaseN.md` (replace `N` with the appropriate phase number). E.g. for `Phase2Tests`, see `Phase2Tests/testDescriptionsPhase2.md`. This documentation provides a general overview arguing the completeness of the test suite. This is followed by a table of all tests, a brief description of what the test accomplishes (Purpose), and a brief description of how the test accomplishes this (Function).

Besides the central documentation file for each phase, there are numerous test files in the phase directory. All files ending in `.pt` are test programs. The expected output for a given test program `<name>.pt` is located in file `<name>.pt.eOutput`. This expected output consists of 3 parts:

1. Output from ptc (which displays syntax errors, if any)
2. A marker denoting end of ptc output (`### END OF PTC OUTPUT ###`)
3. Output from `ssltrace ... -e`, i.e. the emitted tokens

Example:

```
Input token accepted 36;  Line 1;  Next input token 7
Table index 0;  Operation 5;  Argument 7
...
Output token emitted 11
Table index 173;  Operation 1;  Argument 5
Table index 25;  Operation 1;  Argument 8
### END OF PTC OUTPUT ###
 .sProgram
 .sIdentifier
 .sParmEnd
  .sBegin
  .sEnd

```

See details below for generation and verification of test output.

## To run all tests for all phases (`test.sh`)
1. Ensure you are in the `testSuite/` directory
2. Run `./test.sh`

This will run the `test-phase.sh` script in each of the phase directories. See below for an explaination of the single phase test script

**If you intend to use a different library for ptc**, (that is, not the library provided by our source code in `src/lib/pt/`) supply the `-L` flag followed by the (relative or absolute) path to your `lib/pt`. E.g. `./test.sh -L ../../src/lib/pt`. If a relative path is supplied, ensure it is relative to one of the `PhaseXTests/` directories, NOT `testSuite/`, e.g. `./test.sh -L ../../src/lib/pt` will work, `./test.sh -L ../src/lib/pt` will NOT work. (sorry, I'm not great with paths)

## To run all tests for a single phase (`test-phase.sh`)

1. Navigate to the directory for a given phase (e.g. `cd Phase2Tests`)
2. Run `./test-phase.sh`

This script will, for each `*.pt` file, run the appropriate `ptc` and `ssltrace` commands, and then dump the generated `*.eOutput` into the `pX_out` directory. Then, `diff` is used to compare the generated `*.eOutput` to the expected output listed alongside each test program in `PhaseXTests/`.

Output is generally formatted as: a bunch of PT Pascal copyright statements, followed by a listing of test output files and an indication of a pass or fail for each test. If all tests pass, this will be noted at the bottom of the program.

If a given test fails, the diff output will be displayed. Diff output should be interpreted as follows:

- Diff output is seperated into blocks of differing lines
- The top of each diff block has line numbers indicating where in the expected output vs. actual output the block occurs
- Following lines are differences between expected output (lines prefixed with `<`) and actual output (lines prefixed with `>`)
- For more info, see `man diff`

**If you intend to use a different library for ptc**, (that is, not the library provided by our source code in `src/lib/pt/`) supply the `-L` flag followed by the (relative or absolute) path to your `lib/pt`. E.g. `./test-phase.sh -L ../../src/lib/pt`. If a relative path is supplied, ensure it is relative to the `PhaseXTests/` directory you are in.

## To run a single test file (`test-single.sh`)

1. Navigate to the directory for a given phase (e.g. `cd Phase2Tests`)
2. Run `./test-single.sh`

This supports the following flags:

<table>
  <tr>
    <th>Flag</th>
    <th>Value</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>-f</td>
    <td>Path to test program file</td>
    <td><code>./test-single.sh -f choose_positive.pt</code></td>
  </tr>
  <tr>
    <td>-L</td>
    <td>Path to ptc library</td>
    <td><code>./test-single.sh -L "../../src/lib/pt"</code></td>
  </tr>
  <tr>
    <td>-s</td>
    <td>Save output as expected output? (yes or no)</td>
    <td><code>./test-single.sh -s yes</code></td>
  </tr>
  <tr>
    <td>-c</td>
    <td>Compare output to expected output? (yes or no)</td>
    <td><code>./test-single.sh -c yes</code></td>
  </tr>
  <tr>
    <td>-q</td>
    <td>Quiet mode. If supplied, will suppress output to console</td>
    <td><code>./test-single.sh -q</code></td>
  </tr>
</table>

This script will run the appropriate `ptc` and `ssltrace` commands on the test program provided and save generated output in the `pX_out/` directory. Optionally saves generated output as expected output (CAUTION: overwrites existing). Optionally compares expected output to generated output. Comparison output should be interpretted as described above in 'Run all tests for a single phase' section

For all flags except the library flag (`-L`) and quiet flag (`-q`), user will be prompted for a response if flag not supplied in arguments. 

**If you intend to use a different library for ptc**, (that is, not the library provided by our source code in `src/lib/pt/`) supply the `-L` flag followed by the (relative or absolute) path to your `lib/pt`. E.g. `./test-single.sh -L ../../src/lib/pt`. If a relative path is supplied, ensure it is relative to the `PhaseXTests/` directory you are in.

## To generate expected output for all tests (`generate-test-output.sh`)

**CAUTION:** this will overwrite all of the `*.eOutput` expected outputs in the directory

1. Navigate to the directory for a given phase (e.g. `cd Phase2Tests`)
2. Run `./generate-test-output.sh`

This will run `./test-single.sh -L $pt_lib_path -f $pt_src_path -s yes -c no -q` on all files matching `*.pt` in the directory, replacing `$pt_src_path` with each file path and `$pt_lib_path` with the supplied (or default) ptc library path.

**If you intend to use a different library for ptc**, (that is, not the library provided by our source code in `src/lib/pt/`) supply the `-L` flag followed by the (relative or absolute) path to your `lib/pt`. E.g. `./generate-test-output.sh -L ../../src/lib/pt`. If a relative path is supplied, ensure it is relative to the `PhaseXTests/` directory you are in.
