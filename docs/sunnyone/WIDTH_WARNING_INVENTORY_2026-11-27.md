# SUNNYONE — Width Warning Inventory

**Reference:** full-chip Verilator 5.032 lint workflow 45845758782; source SHA 2835f1a8da6af454023caff9576f41258c66e2a8. 79 raw width diagnostics extracted from the archived log on 2026-11-27. This is an inventory, not a closure or waiver.

**Counts:** 52 WIDTHEXPAND and 27 WIDTHTRUNC. Every item remains individually unclassified until signedness, range, truncation intent, parameter bounds and synthesis relevance are reviewed. Simulation-only warnings must be identified by exact SYNTHESIS guards; do not assume all are hardware or harmless.

## Raw warning inventory

### rtl/vpu/otpu_vpu.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 775:18 | WIDTHEXPAND | Operator VAR 'T_EW' expects 32 bits on the Initial value, but Initial value's FUNCREF 'n_slots' generates 4 bits. | OPEN |
| 775:41 | WIDTHEXPAND | Operator VAR 'T_RC' expects 32 bits on the Initial value, but Initial value's FUNCREF 'n_slots' generates 4 bits. | OPEN |
| 775:66 | WIDTHEXPAND | Operator VAR 'T_EX' expects 32 bits on the Initial value, but Initial value's FUNCREF 'n_slots' generates 4 bits. | OPEN |
| 776:18 | WIDTHEXPAND | Operator VAR 'T_RS' expects 32 bits on the Initial value, but Initial value's FUNCREF 'n_slots' generates 4 bits. | OPEN |
| 1057:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1058:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1059:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1067:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1068:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1070:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1071:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1072:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1073:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1074:15 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1074:31 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1074:47 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1099:55 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1099:72 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1100:39 | WIDTHTRUNC | Bit extraction of var[23:0] requires 5 bit index, not 8 bits. | OPEN |
| 1461:11 | WIDTHTRUNC | Bit extraction of array[31:0] requires 5 bit index, not 13 bits. | OPEN |
| 1462:26 | WIDTHTRUNC | Bit extraction of array[31:0] requires 5 bit index, not 13 bits. | OPEN |

### rtl/top/otpu_pkg.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 219:7 | WIDTHEXPAND | Operator ASSIGN expects 32 bits on the Assign RHS, but Assign RHS's REPLICATE generates 31 bits. | OPEN |
| 386:40 | WIDTHEXPAND | Operator ADD expects 32 bits on the RHS, but RHS's REPLICATE generates 21 bits. | OPEN |
| 436:73 | WIDTHEXPAND | Operator ADD expects 32 bits on the RHS, but RHS's REPLICATE generates 21 bits. | OPEN |

### rtl/vpu/otpu_quant.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 1025:17 | WIDTHEXPAND | Operator ADD expects 32 bits on the RHS, but RHS's REPLICATE generates 18 bits. | OPEN |
| 1034:46 | WIDTHEXPAND | Operator SHIFTR expects 32 or 3 bits on the LHS, but LHS's VARREF 'wbo' generates 2 bits. | OPEN |
| 1042:46 | WIDTHEXPAND | Operator SHIFTR expects 32 or 3 bits on the LHS, but LHS's VARREF 'wbo' generates 2 bits. | OPEN |
| 1079:66 | WIDTHEXPAND | Operator SHIFTR expects 32 or 3 bits on the LHS, but LHS's SEL generates 2 bits. | OPEN |
| 1084:44 | WIDTHEXPAND | Operator SHIFTR expects 32 or 3 bits on the LHS, but LHS's VARREF 'sbo' generates 2 bits. | OPEN |
| 1363:36 | WIDTHEXPAND | Operator COND expects 11 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 1363:36 | WIDTHEXPAND | Operator COND expects 11 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 1385:22 | WIDTHEXPAND | Operator ADD expects 32 bits on the RHS, but RHS's REPLICATE generates 3 bits. | OPEN |
| 1454:72 | WIDTHEXPAND | Operator AND expects 32 bits on the LHS, but LHS's REPLICATE generates 21 bits. | OPEN |

### rtl/mxu/otpu_mxu.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 462:52 | WIDTHEXPAND | Operator SUB expects 32 bits on the LHS, but LHS's SEL generates 16 bits. | OPEN |
| 462:52 | WIDTHEXPAND | Operator SUB expects 32 bits on the RHS, but RHS's CONST '16'h1' generates 16 bits. | OPEN |
| 851:63 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'q_n' generates 3 bits. | OPEN |
| 2247:76 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2305:19 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2306:15 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2607:29 | WIDTHTRUNC | Bit extraction of var[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2663:33 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2999:51 | WIDTHEXPAND | Operator ASSIGN expects 8 bits on the Assign RHS, but Assign RHS's CONST '5'h1' generates 5 bits. | OPEN |
| 3000:71 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '5'h10' generates 5 bits. | OPEN |
| 3000:71 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '5'h8' generates 5 bits. | OPEN |
| 3001:72 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '5'h8' generates 5 bits. | OPEN |
| 3001:72 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '5'h4' generates 5 bits. | OPEN |
| 3103:29 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3103:29 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3103:51 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3103:51 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3106:38 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3106:38 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3106:63 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3106:63 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3107:40 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3107:40 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3107:62 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3107:62 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3110:55 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3110:55 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3111:36 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional True, but Conditional True's CONST '1'h1' generates 1 bits. | OPEN |
| 3111:36 | WIDTHEXPAND | Operator COND expects 8 bits on the Conditional False, but Conditional False's CONST '1'h0' generates 1 bits. | OPEN |
| 3290:28 | WIDTHEXPAND | Operator EQ expects 3 bits on the RHS, but RHS's CONST '2'h1' generates 2 bits. | OPEN |
| 3300:29 | WIDTHEXPAND | Operator EQ expects 3 bits on the RHS, but RHS's CONST '2'h1' generates 2 bits. | OPEN |

### rtl/mem/otpu_tmem.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 121:16 | WIDTHEXPAND | Operator GTE expects 32 bits on the LHS, but LHS's SEL generates 3 bits. | OPEN |

### rtl/seq/otpu_seq.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 678:36 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 681:19 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 758:31 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 762:27 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1539:34 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1545:36 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1588:61 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1688:26 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1689:24 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1690:24 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1838:70 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1839:54 | WIDTHEXPAND | Operator NEQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |

### rtl/mem/otpu_dram.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 72:49 | WIDTHTRUNC | Logical operator COND expects 1 bit on the Conditional Test, but Conditional Test's CMETHODHARD 'exists' generates 32 bits. | OPEN |
| 80:26 | WIDTHTRUNC | Logical operator COND expects 1 bit on the Conditional Test, but Conditional Test's CMETHODHARD 'exists' generates 32 bits. | OPEN |

## Triage rules

- First determine whether the statement is inside an ifndef SYNTHESIS region or is part of the synthesizable datapath.
- For arithmetic, document operand width, expression width, signedness, carry/borrow behaviour and legal input range.
- For shifts and indices, prove bounds for every parameter configuration; do not merely cast the index narrower.
- For array accesses, prove the index cannot exceed the declared array bounds under reset, valid, maximum count and boundary cases.
- For assignments, prove whether truncation/extension is intentional and whether discarded bits can be nonzero or affect sign/overflow.
- Apply the smallest explicit-width correction only after proof, then add directed boundary tests and compare against the reference behaviour.
- No blanket casts, warning suppressions or global waiver.

## Priority review order

1. Array-index truncations in VPU/MXU and the sequencer.
2. DMA and address/length arithmetic, including the ASIC AW/AR 34-to-33-bit port warnings from the separate ASIC compile.
3. Shift, mask and quantizer byte-enable expressions.
4. Arithmetic/constant extensions and comparisons.
5. Simulation-only diagnostic/testbench expressions.
