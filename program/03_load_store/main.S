# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

                .text
            lui t0, 0xAAAAA
            addi t0, t0, 0x555
#           lui t1, 0x10010 #addr  -> start addr in RARS
            lui t1, 0x0 #addr
store_data: sw t0, 0(t1) #store data for array -> word (32 bits)
#  sh t0, 0(t1) #store data for array -> halfword (16 bits)
load_data:  lw t2, 0(t1) #load data from array
#end:        beqz zero, end # while(1);