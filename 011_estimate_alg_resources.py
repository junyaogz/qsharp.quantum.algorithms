import qsharp
from qsharp_widgets import EstimateDetails
from qsharp_widgets import SpaceChart

result = qsharp.estimate("RunProgram()")
EstimateDetails(result)

SpaceChart(result)
