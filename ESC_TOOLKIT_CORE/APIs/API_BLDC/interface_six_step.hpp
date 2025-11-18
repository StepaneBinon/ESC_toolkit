/**
 * @brief Pure interface for zero crossing detection.
 * 
 * @tparam Measures Type representing sensor measurement (e.g. voltage).
 */
template <typename Params>
class IZeroCrossingFilter 
{
public:
    // ----------------- Ctors / Dtors -----------------
    IZeroCrossingFilter() noexcept = default;
    // ----------------- Rule of Five -----------------
    IZeroCrossingFilter(const IZeroCrossingFilter&) = default;
    IZeroCrossingFilter(IZeroCrossingFilter&&) noexcept = default;
    IZeroCrossingFilter& operator=(const IZeroCrossingFilter&) = default;
    IZeroCrossingFilter& operator=(IZeroCrossingFilter&&) = default;
    virtual ~IZeroCrossingFilter() = default;

    // ----------------- Methods -----------------
    virtual void set_params(const Params& params) = 0;
    [[nodiscard]] virtual void get_params(const Params& params) = 0;
    /**
     * @brief Notifies the filter of a PWM transition for a given phase.
     *
     * This method is called on each PWM edge (rising or falling) that changes
     * the conduction state of the specified motor 'phase'. It updates the internal
     * blanking timer used to mask transient disturbances caused by switching
     * events.
     *
     * When a phase enters its PWM-OFF window (both transistors off, phase floating),
     * the corresponding 'now_off' flag should be set to 'true'. Conversely, when
     * the phase exits the OFF window (one transistor turns back on), 'now_off'
     * should be set to 'false'.
     *
     * The function records the timestamp of the event and extends the blanking
     * period, during which all back-EMF samples for this phase will be ignored.
     *
     * @param phase   Index of the affected motor phase (e.g., 0=A, 1=B, 2=C).
     * @param now_off  Indicates whether the phase has entered its PWM-OFF window ('true')
     *                or exited it ('false').
     * @param t_ns    Current timestamp in nanoseconds corresponding to the PWM edge.
     *
     * @note Typical use:
     *       - Called from a timer interrupt or DMA callback that marks PWM transitions.
     *       - 'blanking_until_ns' is reset to 't_ns + params_.blanking_ns' each time.
     *       - Depending on the implementation, leaving the OFF window may optionally
     *         disarm the zero-cross detector for additional safety.
     */
    virtual void on_pwm_edge(const uint8_t phase, const bool now_off, const uint32_t t_ns);
};