import Std.Diagnostics.*;
import Std.Convert.*;

operation Main() : Int {
    use qubits = Qubit[3];
    ApplyToEach(H, qubits);
    Message("The qubit register is in a uniform superposition: ");
    DumpMachine();
    mutable results = [];
    for q in qubits {
        Message(" ");
        results += [M(q)];
        DumpMachine();
    }
    ResetAll(qubits);
    Message("Your random number is: ");
    return ResultArrayAsInt(results);
}
