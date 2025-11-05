/**
 * @brief Pure interface for observers.
 * 
 * @tparam Measures Type representing incoming sensor data or signals.
 * @tparam Estimates Type representing estimated system states.
 * @tparam Params Type representing configuration or tuning parameters.
 */
template <typename Measures, typename Estimates, typename Params>
class IObserver
{
public:
    // ----------------- Ctors / Dtors -----------------
    IObserver() noexcept = default;
    // ----------------- Rule of Five -----------------
    IObserver(const IObserver&) = default;
    IObserver(IObserver&&) noexcept = default;
    IObserver& operator=(const IObserver&) = default;
    IObserver& operator=(IObserver&&) = default;
    virtual ~IObserver() = default;

    // ----------------- Methods -----------------
    virtual void set_params(const Params& params) = 0;
    [[nodiscard]] virtual Params get_params() const = 0;
    [[nodiscard]] virtual Estimates update(const Measures& measures) const = 0;
};


/**
 * @brief Pure interface for control algorithms.
 * 
 * @tparam Inputs Type representing controller inputs (e.g. observers data).
 * @tparam Outputs Type representing controller outputs (e.g. PWM commands).
 * @tparam Params Type representing configuration or tuning parameters.
 */
template <typename Inputs, typename Outputs, typename Params>
class IController
{
public:
    // ----------------- Ctors / Dtors -----------------
    IController() noexcept = default;
    // ----------------- Rule of Five -----------------
    IController(const IController&) = default;
    IController(IController&&) noexcept = default;
    IController& operator=(const IController&) = default;
    IController& operator=(IController&&) = default;
    virtual ~IController() = default;

    // ----------------- Methods -----------------
    virtual void set_params(const Params& params) = 0;
    [[nodiscard]] virtual Params get_params() const = 0;
    [[nodiscard]] virtual Outputs step(const Inputs& inputs) const = 0;
};

/**
 * @brief Pure interface for gate driving (e.g. for BLDC phases).
 * 
 * @tparam Inputs Type representing controller inputs (e.g. observers data).
 * @tparam Outputs Type representing controller outputs (e.g. PWM commands).
 * @tparam Params Type representing configuration or tuning parameters.
 */
class IGateDriver
{
public:

};