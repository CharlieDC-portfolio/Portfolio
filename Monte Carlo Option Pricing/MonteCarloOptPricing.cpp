#include <iostream>
#include <cmath>
#include <random>
#include <vector>
#include <functional>

// Function to generate random normal variables using Box-Muller transform
double generate_normal_random() {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::normal_distribution<> dist(0.0, 1.0);  // mean = 0, stddev = 1
    return dist(gen);
}

// Function to simulate the asset price path using Geometric Brownian Motion with dynamic µ and σ
double simulate_asset_price(double S0, double T, int steps,
    //std::function<double(double)> mu_func,
    double risk_free_rate,
    //::function<double(double)> sigma_func
    double volatility) {
    double dt = T / steps;
    double S = S0;

    for (int i = 0; i < steps; ++i) {
        // Calculate the time at this step
        double t = i * dt;

        // Get Constant risk-free rate (µ) and volatility (σ)
        double mu = risk_free_rate;
        double sigma = volatility;

        // Get dynamic risk-free rate (µ) and volatility (σ) for this time step
        //double mu = mu_func(t);
        //double sigma = sigma_func(t);

        // Random increment from Brownian motion (using normal distribution)
        double dW = generate_normal_random() * std::sqrt(dt);

        // Geometric Brownian Motion formula: S(t) = S(t-1) * exp((mu - 0.5*sigma^2)*dt + sigma*dW)
        S *= std::exp((mu - 0.5 * sigma * sigma) * dt + sigma * dW);
    }

    return S;
}

// Function to calculate the payoff for a European call option
double european_call_payoff(double S_T, double K) {
    return std::max(S_T - K, 0.0);
}

// Monte Carlo simulation to price the option with dynamic µ and σ
double monte_carlo_option_price(double S0, double K, double T,
    //std::function<double(double)> mu_func,
    double risk_free_rate,
    //std::function<double(double)> sigma_func,
    double volatility,
    int num_simulations, int steps) {
    double total_payoff = 0.0;

    for (int i = 0; i < num_simulations; ++i) {
        // Simulate the asset price at maturity
        double S_T = simulate_asset_price(S0, T, steps, risk_free_rate, volatility);

        // Calculate the payoff of the European call option
        double payoff = european_call_payoff(S_T, K);

        // Accumulate the discounted payoff
        total_payoff += payoff;
    }

    // Average the total payoff and discount it to present value
    double option_price = (total_payoff / num_simulations);
    return option_price;
}

// Example dynamic risk-free rate function (µ)
double dynamic_risk_free_rate(double t) {
    // For example, linearly increasing µ(t)
    return 0.05 + 0.01 * t; // µ starts at 5% and increases by 1% each year
}

// Example dynamic volatility function (σ)
double dynamic_volatility(double t) {
    // For example, volatility increases with time or could follow some random walk
    return 0.2 + 0.05 * std::sin(t); // Volatility oscillates between 0.15 and 0.25
}

int main() {
    // Option parameters
    double S0 = 100.0;  // Initial asset price
    double K = 100.0;   // Strike price
    double T = 1.0;     // Time to maturity (in years)
    int num_simulations = 10000; // Number of simulations
    int steps = 100;    // Number of time steps per simulation
    double risk_free_rate = 0.0443;//constant risk free rate based on interest rate on 3 month US treasury bill
    double volatility = 0.2;

    // Price the option using Monte Carlo simulation
    double option_price = monte_carlo_option_price(S0, K, T, risk_free_rate, volatility, num_simulations, steps);

    // Output the result
    std::cout << "The estimated price of the European call option is: " << option_price << std::endl;

    return 0;
}