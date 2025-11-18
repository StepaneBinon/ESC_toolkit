/**
 * @brief Pure interface for sensors.
 * 
 * @tparam Measures Type representing sensor measurement (e.g. voltage).
 */
template <typename Measures>
class ISensor
{
public:
    // ----------------- Ctors / Dtors -----------------
    ISensor() noexcept = default;
    // ----------------- Rule of Five -----------------
    ISensor(const ISensor&) = default;
    ISensor(ISensor&&) noexcept = default;
    ISensor& operator=(const ISensor&) = default;
    ISensor& operator=(ISensor&&) = default;
    virtual ~ISensor() = default;

    // ----------------- Methods -----------------
    [[nodiscard]] virtual Measures get_sensed_value() const = 0;
    virtual void set_sensed_value(const Measures& value) = 0;
};

/**
 * @brief Pure interface for voltage sensors (e.g., DC bus or phase voltage).
 */
class IVoltageSensor: public ISensor<double> 
{
public:
    // ----------------- Ctors / Dtors -----------------
    IVoltageSensor() noexcept = default;
    // ----------------- Rule of Five -----------------
    IVoltageSensor(const IVoltageSensor&) = default;
    IVoltageSensor(IVoltageSensor&&) noexcept = default;
    IVoltageSensor& operator=(const IVoltageSensor&) = default;
    IVoltageSensor& operator=(IVoltageSensor&&) = default;
    virtual ~IVoltageSensor() = default;
}; 