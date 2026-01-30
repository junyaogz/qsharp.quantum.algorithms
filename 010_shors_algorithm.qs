import qsharp
from qsharp_widgets import EstimateDetails

%%qsharp
open Microsoft.Quantum.Arrays;
open Microsoft.Quantum.Canon;
open Microsoft.Quantum.Convert;
open Microsoft.Quantum.Diagnostics;
open Microsoft.Quantum.Intrinsic;
open Microsoft.Quantum.Math;
open Microsoft.Quantum.Measurement;
open Microsoft.Quantum.Unstable.Arithmetic;
open Microsoft.Quantum.ResourceEstimation;

operation RunProgram() : Unit {
    let bitsize = 31;

    // When choosing parameters for `EstimateFrequency`, make sure that
    // generator and modules are not co-prime
    let _ = EstimateFrequency(11, 2^bitsize - 1, bitsize);
}


// In this sample we concentrate on costing the `EstimateFrequency`
// operation, which is the core quantum operation in Shor's algorithm, and
// we omit the classical pre- and post-processing.

/// # Summary
/// Estimates the frequency of a generator
/// in the residue ring Z mod `modulus`.
///
/// # Input
/// ## generator
/// The unsigned integer multiplicative order (period)
/// of which is being estimated. Must be co-prime to `modulus`.
/// ## modulus
/// The modulus which defines the residue ring Z mod `modulus`
/// in which the multiplicative order of `generator` is being estimated.
/// ## bitsize
/// Number of bits needed to represent the modulus.
///
/// # Output
/// The numerator k of dyadic fraction k/2^bitsPrecision
/// approximating s/r.
operation EstimateFrequency(
    generator : Int,
    modulus : Int,
    bitsize : Int
)
: Int {
    mutable frequencyEstimate = 0;
    let bitsPrecision =  2 * bitsize + 1;

    // Allocate qubits for the superposition of eigenstates of
    // the oracle that is used in period finding.
    use eigenstateRegister = Qubit[bitsize];

    // Initialize eigenstateRegister to 1, which is a superposition of
    // the eigenstates we are estimating the phases of.
    // We first interpret the register as encoding an unsigned integer
    // in little endian encoding.
    ApplyXorInPlace(1, eigenstateRegister);
    let oracle = ApplyOrderFindingOracle(generator, modulus, _, _);

    // Use phase estimation with a semiclassical Fourier transform to
    // estimate the frequency.
    use c = Qubit();
    for idx in bitsPrecision - 1..-1..0 {
        within {
            H(c);
        } apply {
            // `BeginEstimateCaching` and `EndEstimateCaching` are the operations
            // exposed by the Azure Quantum Resource Estimator. These will instruct
            // resource counting such that the if-block will be executed
            // only once, its resources will be cached, and appended in
            // every other iteration.
            if BeginEstimateCaching("ControlledOracle", SingleVariant()) {
                Controlled oracle([c], (1 <<< idx, eigenstateRegister));
                EndEstimateCaching();
            }
            R1Frac(frequencyEstimate, bitsPrecision - 1 - idx, c);
        }
        if MResetZ(c) == One {
            set frequencyEstimate += 1 <<< (bitsPrecision - 1 - idx);
        }
    }

    // Return all the qubits used for oracles eigenstate back to 0 state
    // using Microsoft.Quantum.Intrinsic.ResetAll.
    ResetAll(eigenstateRegister);

    return frequencyEstimate;
}


