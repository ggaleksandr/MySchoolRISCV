# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

                .text

  lui t0, 0xAAAAA
  addi t0, t0, 0x111
  lui t2, 0xBBBBB
  addi t2, t2, 0x222

  lui t1, 0x0 #addr

store_data: 
  sw t0, 0(t1) #store word (32 bits)
  sw t0, 0(t1) #store zero (32 bits)
  sh t0, 0(t1) #store halfword (16 bits)
  sb t2, 1(t1) #store halfword (16 bits)
  sh t2, 2(t1) #store halfword (16 bits)

load_data:  
  lw t2, 0(t1) #load data from array
  lw t4, 0(t1) #load word (32 bits)
  lbu t4, 1(t1) #load word (8 bits zero extended to 32)
  lb t4, 1(t1) #load word (8 bits)
  lb t4, 0(t1) #load word (8 bits)
  lb t4, 1(t1) #load word (8 bits)
  lb t4, 2(t1) #load word (8 bits)
  lb t4, 3(t1) #load word (8 bits)
  lw t3, 0(t1) #load word (32 bits)

end:        beqz zero, end # while(1);