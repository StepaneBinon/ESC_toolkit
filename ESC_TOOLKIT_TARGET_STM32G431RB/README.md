**Timing breakdown:**
- ADC completes conversion → DMA starts: ~0 cycles (hardware handshake)
- DMA reads DR register: ~0 CPU cycles (bus master access)
- DMA writes to RAM: ~0 CPU cycles (parallel to CPU execution)
- **Total CPU overhead: 0 cycles while scanning**

**One interrupt at end (optional):**
- When all 3 channels complete → single interrupt
- Same ~50-60 cycle overhead, but **only once** instead of 3 times
- **Overhead: ~350ns total vs 1µs without DMA**

**CPU availability:**
- During entire ADC sequence: **CPU completely free** ✓
- Can do Clarke transforms, Park transforms, PI control while ADC runs
- No context switches, no cache thrashing

---

## Performance Comparison Table

| Metric | Without DMA | With DMA | Savings |
|--------|-------------|----------|---------|
| **CPU cycles per conversion** | 50-60 | 0 | 50-60 cycles |
| **CPU cycles for 3 channels** | 150-180 | 0 | 150-180 cycles |
| **Time overhead @ 170MHz** | ~1µs | ~0ns | 1µs |
| **Interrupt count (3 channels)** | 3 | 1 (optional) | 2-3 fewer |
| **CPU free during conversion?** | No (interrupted) | Yes | Critical! |
| **Deterministic timing?** | No (ISR jitter) | Yes | Better |
| **Code complexity** | Medium | Low (setup once) | Simpler |
| **RAM usage** | Minimal | +6 bytes (buffer) | Negligible |

---

## Impact on Your 128 kHz Loop (7.8µs budget)

**Without DMA:**
- ADC conversions: 2µs (hardware)
- Interrupt overhead: 1µs (3 interrupts)
- **Total: 3µs consumed** (38% of budget)
- Remaining: 4.8µs for FOC math

**With DMA:**
- ADC conversions: 2µs (hardware, CPU free during this!)
- Interrupt overhead: 0.35µs (1 interrupt at end, optional)
- **CPU available during entire ADC scan**
- Can pipeline: ADC runs while CPU does previous cycle's FOC calculations
- Effective overhead: **~0.35µs** (4% of budget)
- Remaining: 7.45µs for FOC math

---

## Real-World Example: Your FOC Loop

### **Without DMA - Sequential Execution:**
```
Time:  0µs ──────────────── 7.8µs (loop period)
       ├─ Trigger ADC
       │  └─ Wait ~350ns (ch1 interrupt overhead)
       ├─ Wait for ch1 conversion ~700ns
       │  └─ ISR: read ch1, ~350ns overhead
       ├─ Wait for ch2 conversion ~700ns  
       │  └─ ISR: read ch2, ~350ns overhead
       ├─ Wait for ch3 conversion ~700ns
       │  └─ ISR: read ch3, ~350ns overhead
       ├─ NOW can start Clarke transform (3µs wasted!)
       ├─ Clarke: 200ns
       ├─ Park: 300ns
       ├─ PI controllers: 500ns
       ├─ Inverse Park: 300ns
       ├─ Inverse Clarke: 200ns
       ├─ Update PWM: 100ns
       └─ Done: 5.6µs total
```

**Problem:** CPU blocked during ADC scan, can't overlap operations

### **With DMA - Pipelined Execution:**
```
Time:  0µs ──────────────── 7.8µs (loop period)
       ├─ Trigger ADC+DMA (runs in background)
       ├─ Immediately start Clarke on PREVIOUS cycle data
       ├─ Park transform (ADC still running in parallel)
       ├─ PI controllers (ADC still running)
       ├─ Inverse transforms (ADC completes ~2µs)
       ├─ DMA interrupt: new data ready
       ├─ Update PWM with current calculations
       └─ Done: ~3µs for math, ADC overlapped!