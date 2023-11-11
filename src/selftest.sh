#
#  This will program the registers of the RDMA reference design 
#  to run a self-test.  (You'll need the 'pcireg' utility).
#
#  If the self-test fails, you should probably re-load the bitstream
#  into the FPGA before trying again.
#

# This Ethernet IP reset sequence and register map are from from page 128 of:
# https://docs.xilinx.com/viewer/book-attachment/KjOBPi3JqmLEeXdcXhXzyg/bRkBpLztI2LO~ZutVtlDmw

# Capture the command line parameters
p1=$1
p2=$2

# These are the RDMA packet sizes that we can test
fullset=$((64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192))

# By default, we're going to test all of the packet sizes
testset=${fullset}

# Ensure that $p1 and $p2 have a value
test -z $p1 && p1=1
test -z $p2 && p2=1

# Determine if the user is trying to specify the packet size to test
test $p1 -eq 64   && testset=64
test $p1 -eq 128  && testset=128
test $p1 -eq 256  && testset=256
test $p1 -eq 512  && testset=512
test $p1 -eq 1024 && testset=1024
test $p1 -eq 2048 && testset=2048
test $p1 -eq 4096 && testset=4096
test $p1 -eq 8192 && testset=8192

# Determine how many times to run the test
test $testset -eq $fullset && loops=$p1 || loops=$p2

# This is the PCI base address of the data generator module
BASE_ADDR=0x600

# Compute the addresses of all the data generator AXI registers
REG_INITIAL_VALUE=$((BASE_ADDR +  0))
  REG_WRITE_DELAY=$((BASE_ADDR +  4))
  REG_START_WRITE=$((BASE_ADDR +  8))
    REG_READ_BACK=$((BASE_ADDR + 12))
 REG_NARROW_WRITE=$((BASE_ADDR + 16))


# Base address of Xilinx 100G Ethernet registers
ETH0_BASE=0x10000

# Ethernet port 0 configuration and status registers
           REG_ETH0_RESET=$((ETH0_BASE + 0x0004))
       REG_ETH0_CONFIG_TX=$((ETH0_BASE + 0x000C))
       REG_ETH0_CONFIG_RX=$((ETH0_BASE + 0x0014))
        REG_ETH0_LOOPBACK=$((ETH0_BASE + 0x0090))
         REG_ETH0_STAT_RX=$((ETH0_BASE + 0x0204))
REG_STAT_RX_TOTAL_PACKETS=$((ETH0_BASE + 0x0608))
      REG_STAT_RX_BAD_FCS=$((ETH0_BASE + 0x06C0))
 REG_ETH0_RSFEC_CONFIG_IC=$((ETH0_BASE + 0x1000))
    REG_ETH0_RSFEC_CONFIG=$((ETH0_BASE + 0x107C))
            REG_ETH0_TICK=$((ETH0_BASE + 0x02B0))


#==============================================================================
# This reads a PCI register and displays its value in decimal
#==============================================================================
read_reg()
{
  # Capture the value of the AXI register
  text=$(pcireg $1)

  # Extract just the first word of that text
  text=($text)

  # Convert the text into a number
  value=$((text))

  # Hand the value to the caller
  echo $value
}
#==============================================================================


#==============================================================================
# This enables RS-FEC and achieves PCS alignment
#==============================================================================
enable_ethernet()
{
  # If we already have PCS lock, do nothing.  Issuing a reset to the Ethernet
  # core while it already has PCS does something that causes both the down-
  # stream and upstream FIFOs to misbehave in unpleasant ways.
  status=$(($(read_reg $REG_ETH0_STAT_RX)))
  if [ $status -eq 3 ]; then
      return
  fi
 
  # Disable the Ethernet transmitter
  pcireg $REG_ETH0_CONFIG_TX 0

  # Enable RS-FEC indication and correction
  pcireg $REG_ETH0_RSFEC_CONFIG_IC 3

  # Enable RS-FEC on both TX and RX
  pcireg $REG_ETH0_RSFEC_CONFIG 3

  # Turn on local loopback so that we receive the packets we send
  pcireg $REG_ETH0_LOOPBACK 1

  # Reset the Ethernet core to make the RS-FEC settings take effect
  pcireg $REG_ETH0_RESET 0xC0000000
  pcireg $REG_ETH0_RESET 0x00000000

  # Enable the Ethernet receiver
  pcireg $REG_ETH0_CONFIG_RX 1

  # Enable the transmission of RFI
  pcireg $REG_ETH0_CONFIG_TX 2

  # Wait for PCS alignment
  aligned=0
  for n in {1..20}; 
  do
    status=$(($(read_reg $REG_ETH0_STAT_RX)))
    if [ $status -eq 3 ]; then
      aligned=1
      break
    fi
    sleep .2
  done

  # Enable the Ethernet transmitted
  pcireg $REG_ETH0_CONFIG_TX 1

  # Check to ensure that we have Ethernet PCS alignment
  if [ $aligned -eq 0 ]; then
      echo "PCS alignment failed!"
      exit 1
  fi

  # Let the use know that all is well in Ethernet-land
  echo "Ethernet enabled"
}
#==============================================================================




#==============================================================================
# This runs a single test.   It should be passed a packet-length that is a
# power of 2 between 64 and 8192.
#==============================================================================
run_test ()
{
  packet_length=$1

  # Tell the user what we're doing
  echo -n "Testing with packet size $1...  "

  # This value will be written to the 32-bit word at RAM address 0
  # This can be any arbitrary value
  pcireg $REG_INITIAL_VALUE $RANDOM

  # Allow 25 clock cycles between write transactions so we don't overflow
  # the Ethernet receive FIFO
  pcireg $REG_WRITE_DELAY 25

  # Fill RAM with data, using RDMA packets of the specified size.
  # This can be any power of 2 between 64 and 8192
  pcireg $REG_START_WRITE $packet_length

  # Wait for RAM to fill
  for (( ; ; ))
  do
    status=$(($(read_reg $REG_START_WRITE)))
    if [ $status -eq 1 ]; then
      break;
    fi   
  done
  
  # Read back RAM 
  pcireg $REG_READ_BACK 1

  # Wait for the read-back to complete
  for (( ; ; ))
  do
    status=$(($(read_reg $REG_READ_BACK)))
    if [ $status -eq 1 ] || [ $status -eq 3 ]; then
      break;
    fi   
  done
    
  # Determine whether the test passed or failed.  If the
  # test failed, capture the Ethernet statics registers
  if [ $status -eq 3 ]; then
    echo "Passed"
  else
    echo "FAILED"
    pcireg $REG_ETH0_TICK 1  
    echo -n "There were" $(($(read_reg $REG_STAT_RX_BAD_FCS))) "bad packets "
    echo "out of a total of" $(($(read_reg $REG_STAT_RX_TOTAL_PACKETS)))
    exit 1
  fi
}
#==============================================================================

# why can't I read 0x500??
#  Test incoming UDP packets from PC
#  Change all the qsfp_xxx signal names to eth_xxx


# Check to make sure the PCI bus sees our FPGA
reg=$(($(read_reg $REG_INITIAL_VALUE)))
if [ $reg -eq $((0xFFFFFFFF)) ]; then
    echo "You forgot to issue a hot_reset"
    exit 1
fi

# Make sure that our Ethernet channel is up
enable_ethernet

# Run a self-test at every legal packet size
for (( n=1 ; n<=$loops ; n++ )); 
do
  echo ">>>>> Test $n <<<<<"
  test $((testset &   64)) -ne 0 && run_test "  64"  
  test $((testset &  128)) -ne 0 && run_test " 128"
  test $((testset &  256)) -ne 0 && run_test " 256"
  test $((testset &  512)) -ne 0 && run_test " 512"
  test $((testset & 1024)) -ne 0 && run_test "1024"
  test $((testset & 2048)) -ne 0 && run_test "2048"
  test $((testset & 4096)) -ne 0 && run_test "4096"
  test $((testset & 8192)) -ne 0 && run_test "8192"
done

exit 0
