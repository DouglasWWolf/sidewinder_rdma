          CTRL=0x604
        STATUS=0x604
       LOAD_F0=0x608
        COUNT0=0x608
       LOAD_F1=0x60C
        COUNT1=0x60C
         START=0x610
CYCLES_PER_ROW=0x614
ROWS_PER_FRAME=0x618
         VALUE=0x640

# bit values
LOAD0=4
LOAD1=8

# Make the frame geometry easily visible in the debugger
pcireg $CYCLES_PER_ROW 4
pcireg $ROWS_PER_FRAME 3

# Reset both FIFOS
pcireg $CTRL 3
pcireg $STATUS
pcireg $STATUS
pcireg $STATUS

# Store an entry in fifo_0
pcireg $LOAD_F0 0x00112233
pcireg $COUNT0

# Store an entry in fifo_0
pcireg $LOAD_F0 0x44556677
pcireg $COUNT0

# Store an entry in fifo_0
pcireg $LOAD_F0 0x8899AABB
pcireg $COUNT0

# Store an entry in fifo_0
pcireg $LOAD_F0 0xCCDDEEFF
pcireg $COUNT0

# Store an entry in fifo_1      
pcireg $VALUE 0x00010203
pcireg $CTRL $LOAD1
pcireg $COUNT1

# Store an entry in fifo_1      
pcireg $VALUE 0x04050607
pcireg $CTRL $LOAD1
pcireg $COUNT1

# Store an entry in fifo_1      
pcireg $VALUE 0x08090A0B
pcireg $CTRL $LOAD1
pcireg $COUNT1

# Store an entry in fifo_1      
pcireg $VALUE 0x0C0D0E0F
pcireg $CTRL $LOAD1
pcireg $COUNT1

