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
| 1454:72 | WIDTHEXPAND | Operator AND expects 32 bits on the LHS, but LHS's REPLICATE generates 21 bits. | SIM_ONLY |

### rtl/mxu/otpu_mxu.sv

| Line:column | Class | Verilator diagnostic | Status |
|---:|---|---|---|
| 462:52 | WIDTHEXPAND | Operator SUB expects 32 bits on the LHS, but LHS's SEL generates 16 bits. | OPEN |
| 462:52 | WIDTHEXPAND | Operator SUB expects 32 bits on the RHS, but RHS's CONST '16'h1' generates 16 bits. | OPEN |
| 851:63 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'q_n' generates 3 bits. | OPEN |
| 2247:76 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | OPEN |
| 2305:19 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | SIM_ONLY |
| 2306:15 | WIDTHTRUNC | Bit extraction of array[7:0] requires 3 bit index, not 4 bits. | SIM_ONLY |
| 2607:29 | WIDTHTRUNC | Bit extraction of var[7:0] requires 3 bit index, not 4 bits. | SIM_ONLY |
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
| 678:36 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | SIM_ONLY |
| 681:19 | WIDTHEXPAND | Operator LT expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | SIM_ONLY |
| 758:31 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 762:27 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | SIM_ONLY |
| 1539:34 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1545:36 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1588:61 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | OPEN |
| 1688:26 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1689:24 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1690:24 | WIDTHTRUNC | Bit extraction of array[3:0] requires 2 bit index, not 3 bits. | OPEN |
| 1838:70 | WIDTHEXPAND | Operator EQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | SIM_ONLY |
| 1839:54 | WIDTHEXPAND | Operator NEQ expects 32 bits on the LHS, but LHS's VARREF 'c_unit' generates 3 bits. | SIM_ONLY |

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


## Preliminary synthesis-guard classification — 2026-11-27

The archived full-chip lint log was cross-checked against source ifndef SYNTHESIS regions. Nine width-warning instances are inside simulation-only code and are not part of the ASIC synthesis source when SYNTHESIS is defined:
- rtl/vpu/otpu_quant.sv:1454
- rtl/mxu/otpu_mxu.sv:2305, 2306, 2607
- rtl/seq/otpu_seq.sv:678, 681, 762, 1838, 1839

These are marked SIM_ONLY in the table; they remain lint diagnostics but are not hardware-width defects. Other warnings remain OPEN until their actual synthesis/configuration relevance and semantics are proven. The rtl/mem/otpu_dram.sv exists() warnings are in the simulation DRAM model and require confirmation against the exact ASIC source list before classifying them as non-hardware.

## High-priority bounds risks identified for proof

1. VPU row-sum buffer: rtl/vpu/otpu_vpu.sv lines 1461–1462 index rb[NRB/LANES] using rows_done[15:LW] and fl[15:LW]. NRB is 256. The legal row-count path appears intended to keep the index in range, but the 13-bit index warning requires a proof that every write/read occurs with row index < NRB and no final-cycle/off-by-one access. RDOT's rdb_i gate includes rows <= NRB; FSUM's shape check is currently in simulation-only code and must be reconciled with the hardware input-validity contract.
2. Sequencer loop stack: rtl/seq/otpu_seq.sv lines 1688–1690 index four-entry arrays with three-bit sp. The ISA documentation states loop nesting depth 4, so legal pushes should use indices 0–3. The RTL does not visibly guard sp < 4 at the push site. Prove the input-program validation contract and add a hardware-safe overflow/error response if malformed programs can reach this path.
3. VPU one-hot function selects: rtl/vpu/otpu_vpu.sv lines 1057–1100 index 24-bit function masks with wider enum/op indices. Prove every enumerated VOP index is within 0–23, then use a precisely sized index only if the proof and all parameter variants agree.
4. MXU drain/key arrays: rtl/mxu/otpu_mxu.sv lines 2247 and 2663 use wider indices into eight-entry arrays. The drain helper has an explicit bounds conditional; prove the index expression is within MCOLS before access. Prove mxm/mx_i bounds for mx_key access before narrowing.
5. Other width extensions (constants, arithmetic and shifts) need expression-width/signedness analysis; a warning is not automatically a functional defect and must not be silenced with a blind cast.

No RTL was changed. The full 79-warning inventory is retained; all SIM_ONLY labels are source-guard classifications, not waivers or overall lint closure.
