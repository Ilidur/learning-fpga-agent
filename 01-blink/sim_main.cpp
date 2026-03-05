// Verilator simulation testbench for blink LED
// This simulates enough clock cycles to see a few LED toggles

#include <iostream>
#include "Vtop.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vtop* top = new Vtop;

    std::cout << "Starting simulation..." << std::endl;
    std::cout << "LED toggles every 13.5M cycles (0.5s at 27MHz)" << std::endl;
    std::cout << std::endl;

    int last_led = -1;
    int toggle_count = 0;

    // Simulate 50 million cycles (about 2 seconds at 27MHz)
    // This should show ~4 LED toggles
    for (uint64_t cycle = 0; cycle < 50000000 && toggle_count < 4; cycle++) {
        // Toggle clock
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();

        // Report when LED changes
        if (top->led != last_led) {
            std::cout << "Cycle " << cycle << ": LED = " << (int)top->led
                      << " (LED is " << (top->led ? "OFF" : "ON") << ")"
                      << std::endl;
            last_led = top->led;
            toggle_count++;
        }
    }

    std::cout << std::endl;
    std::cout << "Simulation complete! LED toggled " << toggle_count << " times." << std::endl;

    top->final();
    delete top;
    return 0;
}
