import Std.Diagnostics.*;
import Std.Math.*;

operation Main() : Result {
    use q = Qubit();
    let P = 0.333333; // P is 1/3
    Ry(2.0 * ArcCos(Sqrt(P)), q);
    Message("The qubit is in the desired state.");
    DumpMachine(); // Dump the state of the qubit 
    Message("Your skewed random bit is:");
    let skewedrandomBit = M(q);
    Reset(q);
    return skewedrandomBit;
}
