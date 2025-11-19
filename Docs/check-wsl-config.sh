#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║   WSL Configuration Verification       ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Memory Check
echo "📊 Memory Configuration:"
total_mem=$(free -h | grep "Mem:" | awk '{print $2}')
used_mem=$(free -h | grep "Mem:" | awk '{print $3}')
avail_mem=$(free -h | grep "Mem:" | awk '{print $7}')
echo "   Total:     $total_mem"
echo "   Used:      $used_mem"
echo "   Available: $avail_mem"
echo ""

# Swap Check
echo "💾 Swap Configuration:"
total_swap=$(free -h | grep "Swap:" | awk '{print $2}')
used_swap=$(free -h | grep "Swap:" | awk '{print $3}')
echo "   Total: $total_swap"
echo "   Used:  $used_swap"
echo ""

# CPU Check
echo "🖥️  CPU Configuration:"
cpu_count=$(nproc)
echo "   Processors: $cpu_count cores"
echo ""

# Detailed Memory
echo "📋 Detailed Information:"
total_ram_gb=$(awk '/MemTotal/ {printf "%.2f", $2/1024/1024}' /proc/meminfo)
total_swap_gb=$(awk '/SwapTotal/ {printf "%.2f", $2/1024/1024}' /proc/meminfo)
echo "   Total RAM:  ${total_ram_gb} GB"
echo "   Total Swap: ${total_swap_gb} GB"
echo ""

# Nested Virtualization Check
echo "🔧 Nested Virtualization:"
if grep -q -E "vmx|svm" /proc/cpuinfo 2>/dev/null; then
    echo "   ✓ Enabled (Hardware virtualization available)"
else
    echo "   ✗ Disabled or not supported"
fi
echo ""

# Kernel Command Line
echo "⚙️  Kernel Parameters:"
kernel_cmd=$(cat /proc/cmdline)
echo "   $kernel_cmd"
echo ""

echo "════════════════════════════════════════"
echo "✅ Configuration check complete!"
echo ""
echo "Expected values for 32GB system with .wslconfig:"
echo "  • Memory: ~16 GB (or as configured)"
echo "  • Processors: 12 (or as configured)"
echo "  • Swap: ~8 GB (or as configured)"
echo ""
echo "If values don't match, run: wsl --shutdown"
echo "Then restart WSL and check again."
echo "════════════════════════════════════════"
