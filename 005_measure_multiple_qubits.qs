import Std.Diagnostics.*;
import Std.Convert.*;

operation Main() : Int {
    use qubits = Qubit[3];
    ApplyToEach(H, qubits);
    Message("The qubit register in a uniform superposition: ");
    DumpMachine();
    let result = MeasureEachZ(qubits);
    Message("Measuring the qubits collapses the superposition to a basis state.");
    DumpMachine();
    ResetAll(qubits);
    return ResultArrayAsInt(result);
}
