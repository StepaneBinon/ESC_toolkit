# VESC code analysis

For 6 step control, VESC relies on edge aligned PWM. Why?

Advantages of center align PWM:
- Lower switching harmonics -> less EMI and torque ripples
- Symetric edges -> 
- Two update point for PWM params per period -> finner granularity

Advantages of edge align PWM
- 

Reducing PWM freq at high speed does not seems a good idea as it decrease the temporal resolution used to compute the ZC => introduce timing jitter. This should still be true with a simpler comparator. At high PWM, commutation latency starts to matter a lot -> fewer mqrgin with low frequency. VESC prefers timing precision other BEMF clarity at high duty. It also create a case edge. Finally, low freq at high duty increase current ripple, worsens the current limitation and strasses the mostfets. In the end, the gain does not balances the risks. For VESC, as they must adapt to a lot of motors, this becomes difficult. But a more specilised soft can make the diff.