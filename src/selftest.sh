#
#  This will program the registers of the RDMA reference design 
#  to run a self-test.  (You'll need the 'pcireg' utility).
#
#  If the self-test fails, you should probably re-load the bitstream
#  into the FPGA before trying again.
#

# This is the PCI base address of the data generator module
BASE_ADDR=0x600

# Compute the values of all the AXI registers
REG_INITIAL_VALUE=$((BASE_ADDR +  0))
  REG_WRITE_DELAY=$((BASE_ADDR +  4))
  REG_START_WRITE=$((BASE_ADDR +  8))
    REG_READ_BACK=$((BASE_ADDR + 12))
 REG_NARROW_WRITE=$((BASE_ADDR + 16))

# The value written to the 32-bit word at RAM address 0 will be 1
# This can be any arbitrary value
pcireg $REG_INITIAL_VALUE 1

# Allow 100 clock cycles between write transactions so we don't overflow
# the Ethernet receive FIFO
pcireg $REG_WRITE_DELAY 200

# Fill RAM with data, 256 bytes at a time.  This can be any power of 2 between
# 64 and 8192
pcireg $REG_START_WRITE 8192

# Wait for RAM to fill
sleep 1

# Read back RAM 
pcireg $REG_READ_BACK 1

# Wait for the read-back to complete
sleep 1

# Capture the status of the read-back
status_text=$(pcireg $REG_READ_BACK)

# Extract just the first word of that text
status=($status_text)

# Convert the text into a number
status=$((status))

# Determine whether the test passed or failed
if [ $status -eq 3 ]; then
  echo "Passed"
else
  echo "Failed"
fi
