import qsharp
from qsharp_widgets import EstimateDetails

result = qsharp.estimate("RunProgram()")

EstimateDetails(result)
