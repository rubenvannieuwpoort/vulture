# Memory

The code for the MCB is in `src/memory_controller/generated`. It is Xilinx IP generated by the CORE generator, slightly edited to move the clock generation out. It is configued as a 166MHz MT46H32M16 LPDDR on bank 3 with two 32-bit bi-directional ports. It uses a single-ended clock and uses round robin arbitration.

To make changes to the memory, I recommend
  - Using ISE project navigation to add an IP core. Choose Spartan-6 memory interface and name it mem32.
  - Configure it with the settings mentioned above.
  - Now copy `mem32.vhd` and `memc3_wrapper.vhd` from `ipcore_dir/mem32/user_design/rtl` to `src/memory_interface/generated`

Now, `mem32.vhd` needs to be changed slightly. I recommend using an IDE with diff capabilities so you can see what changes I made in that file, and re-apply those. The changes should consist of:
  1. Adding some clock ports as input instead of internal signals
  2. Removing the clocking logic

If you add or remove ports, `src/memory_controller/memory_interface.vhd` should be changed accordingly.


## Memory map

```
0x00000000
           main memory (64 MiB, read/write/execute)
0x04000000
           (unmapped, read/write will result in an exception)
0x06000000
           boot ram (4 KiB, read/write/execute)
0x06001000
           font ram (4 KiB, non-executable; trying to execute will result in exception)
0x06002000
           text buffer ram (8 KiB, non-executable; trying to execute will result in exception)
0x06004000
           (unmapped, read/write/execute will result in an exception)
0xffffffff
```

The screenbuffer currently resides at a hardcoded location of `0x03000000`. When (if) I introduce caching, writes to the screenbuffer should never be cached, so the cache should either be write-through, or there should be an uncached region reserved for the screenbuffer (I think using the last 16 MB of the 64 MB main memory would be sufficient).