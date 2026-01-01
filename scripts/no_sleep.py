#!/usr/bin/env python3
import time
import subprocess
import os
import random
import sys

touch_file = "/tmp/keepalive"

def simulate_activity():
    """Main function that simulates different types of system activity"""
    
    # List of xdotool commands for "safe" keys
    safe_keys = ["shift", "ctrl", "alt", "super"]  # Modifier keys
    
    # 1. CPU activity (varies intensity randomly)
    cpu_duration = random.uniform(0.05, 0.2)
    end_time = time.time() + cpu_duration
    operations = 0
    while time.time() < end_time:
        _ = 12345.67 * 67890.12  # Float operation for more "realism"
        operations += 1
    
    # 2. Keyboard activity (uses safe keys)
    try:
        key = random.choice(safe_keys)
        subprocess.run(["xdotool", "key", key], 
                      stdout=subprocess.DEVNULL, 
                      stderr=subprocess.DEVNULL)
    except Exception:
        pass  # Continue even if xdotool fails
    
    # 3. Disk activity (also varies)
    subprocess.run(["touch", touch_file])
    
    # 4. Occasional network activity (every 3 cycles)
    if random.randint(1, 3) == 1:
        try:
            # Light ping to check connectivity
            subprocess.run(["ping", "-c", "1", "8.8.8.8"], 
                          stdout=subprocess.DEVNULL, 
                          stderr=subprocess.DEVNULL)
        except Exception:
            pass
    
    # 5. Occasional log generation (every 10 cycles) for monitoring
    if random.randint(1, 10) == 1:
        with open("/tmp/keepalive.log", "a") as f:
            f.write(f"{time.ctime()}: Cycle OK (CPU ops: {operations})\n")
    
    return operations

def main():
    """Main function with error handling"""
    print(f"Starting anti-hibernation script at {time.ctime()}")
    print("Press Ctrl+C to exit")
    
    cycle_count = 0
    try:
        while True:
            ops = simulate_activity()
            cycle_count += 1
            
            # Console log every 5 cycles
            if cycle_count % 5 == 0:
                print(f"Cycle {cycle_count}: Simulated activity (CPU ops: {ops})")
            
            # Variable interval between 4-6 minutes (makes it less predictable)
            sleep_time = random.uniform(240, 360)  # 4-6 minutes
            time.sleep(sleep_time)
            
    except KeyboardInterrupt:
        print("\nScript interrupted by user")
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        print("Script finished")

if __name__ == "__main__":
    main()