; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -target-abi=ilp32f -code-model=small -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I-SMALL
; RUN: llc -mtriple=riscv32 -mattr=+f -target-abi=ilp32f -code-model=medium -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I-MEDIUM
; RUN: llc -mtriple=riscv64 -mattr=+f -target-abi=lp64f -code-model=small -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I-SMALL
; RUN: llc -mtriple=riscv64 -mattr=+f -target-abi=lp64f -code-model=medium -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I-MEDIUM
; RUN: llc -mtriple=riscv64 -mattr=+f -target-abi=lp64f -code-model=large -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I-LARGE

; Check lowering of globals
@G = global i32 0

define i32 @lower_global(i32 %a) nounwind {
; RV32I-SMALL-LABEL: lower_global:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(G)
; RV32I-SMALL-NEXT:    lw a0, %lo(G)(a0)
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_global:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .Lpcrel_hi0:
; RV32I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(G)
; RV32I-MEDIUM-NEXT:    lw a0, %pcrel_lo(.Lpcrel_hi0)(a0)
; RV32I-MEDIUM-NEXT:    ret
;
; RV64I-SMALL-LABEL: lower_global:
; RV64I-SMALL:       # %bb.0:
; RV64I-SMALL-NEXT:    lui a0, %hi(G)
; RV64I-SMALL-NEXT:    lw a0, %lo(G)(a0)
; RV64I-SMALL-NEXT:    ret
;
; RV64I-MEDIUM-LABEL: lower_global:
; RV64I-MEDIUM:       # %bb.0:
; RV64I-MEDIUM-NEXT:  .Lpcrel_hi0:
; RV64I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(G)
; RV64I-MEDIUM-NEXT:    lw a0, %pcrel_lo(.Lpcrel_hi0)(a0)
; RV64I-MEDIUM-NEXT:    ret
;
; RV64I-LARGE-LABEL: lower_global:
; RV64I-LARGE:       # %bb.0:
; RV64I-LARGE-NEXT:  .Lpcrel_hi0:
; RV64I-LARGE-NEXT:    auipc a0, %pcrel_hi(.LCPI0_0)
; RV64I-LARGE-NEXT:    ld a0, %pcrel_lo(.Lpcrel_hi0)(a0)
; RV64I-LARGE-NEXT:    lw a0, 0(a0)
; RV64I-LARGE-NEXT:    ret
  %1 = load volatile i32, ptr @G
  ret i32 %1
}

; Check lowering of blockaddresses

@addr = global ptr null

define void @lower_blockaddress() nounwind {
; RV32I-SMALL-LABEL: lower_blockaddress:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(addr)
; RV32I-SMALL-NEXT:    li a1, 1
; RV32I-SMALL-NEXT:    sw a1, %lo(addr)(a0)
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_blockaddress:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .Lpcrel_hi1:
; RV32I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(addr)
; RV32I-MEDIUM-NEXT:    li a1, 1
; RV32I-MEDIUM-NEXT:    sw a1, %pcrel_lo(.Lpcrel_hi1)(a0)
; RV32I-MEDIUM-NEXT:    ret
;
; RV64I-SMALL-LABEL: lower_blockaddress:
; RV64I-SMALL:       # %bb.0:
; RV64I-SMALL-NEXT:    lui a0, %hi(addr)
; RV64I-SMALL-NEXT:    li a1, 1
; RV64I-SMALL-NEXT:    sd a1, %lo(addr)(a0)
; RV64I-SMALL-NEXT:    ret
;
; RV64I-MEDIUM-LABEL: lower_blockaddress:
; RV64I-MEDIUM:       # %bb.0:
; RV64I-MEDIUM-NEXT:  .Lpcrel_hi1:
; RV64I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(addr)
; RV64I-MEDIUM-NEXT:    li a1, 1
; RV64I-MEDIUM-NEXT:    sd a1, %pcrel_lo(.Lpcrel_hi1)(a0)
; RV64I-MEDIUM-NEXT:    ret
;
; RV64I-LARGE-LABEL: lower_blockaddress:
; RV64I-LARGE:       # %bb.0:
; RV64I-LARGE-NEXT:  .Lpcrel_hi1:
; RV64I-LARGE-NEXT:    auipc a0, %pcrel_hi(.LCPI1_0)
; RV64I-LARGE-NEXT:    ld a0, %pcrel_lo(.Lpcrel_hi1)(a0)
; RV64I-LARGE-NEXT:    li a1, 1
; RV64I-LARGE-NEXT:    sd a1, 0(a0)
; RV64I-LARGE-NEXT:    ret
  store volatile ptr blockaddress(@lower_blockaddress, %block), ptr @addr
  ret void

block:
  unreachable
}

; Check lowering of blockaddress that forces a displacement to be added

define signext i32 @lower_blockaddress_displ(i32 signext %w) nounwind {
; RV32I-SMALL-LABEL: lower_blockaddress_displ:
; RV32I-SMALL:       # %bb.0: # %entry
; RV32I-SMALL-NEXT:    addi sp, sp, -16
; RV32I-SMALL-NEXT:    lui a1, %hi(.Ltmp0)
; RV32I-SMALL-NEXT:    addi a1, a1, %lo(.Ltmp0)
; RV32I-SMALL-NEXT:    li a2, 101
; RV32I-SMALL-NEXT:    sw a1, 8(sp)
; RV32I-SMALL-NEXT:    blt a0, a2, .LBB2_3
; RV32I-SMALL-NEXT:  # %bb.1: # %if.then
; RV32I-SMALL-NEXT:    lw a0, 8(sp)
; RV32I-SMALL-NEXT:    jr a0
; RV32I-SMALL-NEXT:  .Ltmp0: # Block address taken
; RV32I-SMALL-NEXT:  .LBB2_2: # %return
; RV32I-SMALL-NEXT:    li a0, 4
; RV32I-SMALL-NEXT:    addi sp, sp, 16
; RV32I-SMALL-NEXT:    ret
; RV32I-SMALL-NEXT:  .LBB2_3: # %return.clone
; RV32I-SMALL-NEXT:    li a0, 3
; RV32I-SMALL-NEXT:    addi sp, sp, 16
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_blockaddress_displ:
; RV32I-MEDIUM:       # %bb.0: # %entry
; RV32I-MEDIUM-NEXT:    addi sp, sp, -16
; RV32I-MEDIUM-NEXT:  .Lpcrel_hi2:
; RV32I-MEDIUM-NEXT:    auipc a1, %pcrel_hi(.Ltmp0)
; RV32I-MEDIUM-NEXT:    addi a1, a1, %pcrel_lo(.Lpcrel_hi2)
; RV32I-MEDIUM-NEXT:    li a2, 101
; RV32I-MEDIUM-NEXT:    sw a1, 8(sp)
; RV32I-MEDIUM-NEXT:    blt a0, a2, .LBB2_3
; RV32I-MEDIUM-NEXT:  # %bb.1: # %if.then
; RV32I-MEDIUM-NEXT:    lw a0, 8(sp)
; RV32I-MEDIUM-NEXT:    jr a0
; RV32I-MEDIUM-NEXT:  .Ltmp0: # Block address taken
; RV32I-MEDIUM-NEXT:  .LBB2_2: # %return
; RV32I-MEDIUM-NEXT:    li a0, 4
; RV32I-MEDIUM-NEXT:    addi sp, sp, 16
; RV32I-MEDIUM-NEXT:    ret
; RV32I-MEDIUM-NEXT:  .LBB2_3: # %return.clone
; RV32I-MEDIUM-NEXT:    li a0, 3
; RV32I-MEDIUM-NEXT:    addi sp, sp, 16
; RV32I-MEDIUM-NEXT:    ret
;
; RV64I-SMALL-LABEL: lower_blockaddress_displ:
; RV64I-SMALL:       # %bb.0: # %entry
; RV64I-SMALL-NEXT:    addi sp, sp, -16
; RV64I-SMALL-NEXT:    lui a1, %hi(.Ltmp0)
; RV64I-SMALL-NEXT:    addi a1, a1, %lo(.Ltmp0)
; RV64I-SMALL-NEXT:    li a2, 101
; RV64I-SMALL-NEXT:    sd a1, 8(sp)
; RV64I-SMALL-NEXT:    blt a0, a2, .LBB2_3
; RV64I-SMALL-NEXT:  # %bb.1: # %if.then
; RV64I-SMALL-NEXT:    ld a0, 8(sp)
; RV64I-SMALL-NEXT:    jr a0
; RV64I-SMALL-NEXT:  .Ltmp0: # Block address taken
; RV64I-SMALL-NEXT:  .LBB2_2: # %return
; RV64I-SMALL-NEXT:    li a0, 4
; RV64I-SMALL-NEXT:    addi sp, sp, 16
; RV64I-SMALL-NEXT:    ret
; RV64I-SMALL-NEXT:  .LBB2_3: # %return.clone
; RV64I-SMALL-NEXT:    li a0, 3
; RV64I-SMALL-NEXT:    addi sp, sp, 16
; RV64I-SMALL-NEXT:    ret
;
; RV64I-MEDIUM-LABEL: lower_blockaddress_displ:
; RV64I-MEDIUM:       # %bb.0: # %entry
; RV64I-MEDIUM-NEXT:    addi sp, sp, -16
; RV64I-MEDIUM-NEXT:  .Lpcrel_hi2:
; RV64I-MEDIUM-NEXT:    auipc a1, %pcrel_hi(.Ltmp0)
; RV64I-MEDIUM-NEXT:    addi a1, a1, %pcrel_lo(.Lpcrel_hi2)
; RV64I-MEDIUM-NEXT:    li a2, 101
; RV64I-MEDIUM-NEXT:    sd a1, 8(sp)
; RV64I-MEDIUM-NEXT:    blt a0, a2, .LBB2_3
; RV64I-MEDIUM-NEXT:  # %bb.1: # %if.then
; RV64I-MEDIUM-NEXT:    ld a0, 8(sp)
; RV64I-MEDIUM-NEXT:    jr a0
; RV64I-MEDIUM-NEXT:  .Ltmp0: # Block address taken
; RV64I-MEDIUM-NEXT:  .LBB2_2: # %return
; RV64I-MEDIUM-NEXT:    li a0, 4
; RV64I-MEDIUM-NEXT:    addi sp, sp, 16
; RV64I-MEDIUM-NEXT:    ret
; RV64I-MEDIUM-NEXT:  .LBB2_3: # %return.clone
; RV64I-MEDIUM-NEXT:    li a0, 3
; RV64I-MEDIUM-NEXT:    addi sp, sp, 16
; RV64I-MEDIUM-NEXT:    ret
;
; RV64I-LARGE-LABEL: lower_blockaddress_displ:
; RV64I-LARGE:       # %bb.0: # %entry
; RV64I-LARGE-NEXT:    addi sp, sp, -16
; RV64I-LARGE-NEXT:  .Lpcrel_hi2:
; RV64I-LARGE-NEXT:    auipc a1, %pcrel_hi(.Ltmp0)
; RV64I-LARGE-NEXT:    addi a1, a1, %pcrel_lo(.Lpcrel_hi2)
; RV64I-LARGE-NEXT:    li a2, 101
; RV64I-LARGE-NEXT:    sd a1, 8(sp)
; RV64I-LARGE-NEXT:    blt a0, a2, .LBB2_3
; RV64I-LARGE-NEXT:  # %bb.1: # %if.then
; RV64I-LARGE-NEXT:    ld a0, 8(sp)
; RV64I-LARGE-NEXT:    jr a0
; RV64I-LARGE-NEXT:  .Ltmp0: # Block address taken
; RV64I-LARGE-NEXT:  .LBB2_2: # %return
; RV64I-LARGE-NEXT:    li a0, 4
; RV64I-LARGE-NEXT:    addi sp, sp, 16
; RV64I-LARGE-NEXT:    ret
; RV64I-LARGE-NEXT:  .LBB2_3: # %return.clone
; RV64I-LARGE-NEXT:    li a0, 3
; RV64I-LARGE-NEXT:    addi sp, sp, 16
; RV64I-LARGE-NEXT:    ret
entry:
  %x = alloca ptr, align 8
  store ptr blockaddress(@lower_blockaddress_displ, %test_block), ptr %x, align 8
  %cmp = icmp sgt i32 %w, 100
  br i1 %cmp, label %if.then, label %if.end

if.then:
  %addr = load ptr, ptr %x, align 8
  br label %indirectgoto

if.end:
  br label %return

test_block:
  br label %return

return:
  %retval = phi i32 [ 3, %if.end ], [ 4, %test_block ]
  ret i32 %retval

indirectgoto:
  indirectbr ptr %addr, [ label %test_block ]
}

; Check lowering of constantpools

define float @lower_constantpool(float %a) nounwind {
; RV32I-SMALL-LABEL: lower_constantpool:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(.LCPI3_0)
; RV32I-SMALL-NEXT:    flw fa5, %lo(.LCPI3_0)(a0)
; RV32I-SMALL-NEXT:    fadd.s fa0, fa0, fa5
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_constantpool:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .Lpcrel_hi3:
; RV32I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(.LCPI3_0)
; RV32I-MEDIUM-NEXT:    flw fa5, %pcrel_lo(.Lpcrel_hi3)(a0)
; RV32I-MEDIUM-NEXT:    fadd.s fa0, fa0, fa5
; RV32I-MEDIUM-NEXT:    ret
;
; RV64I-SMALL-LABEL: lower_constantpool:
; RV64I-SMALL:       # %bb.0:
; RV64I-SMALL-NEXT:    lui a0, %hi(.LCPI3_0)
; RV64I-SMALL-NEXT:    flw fa5, %lo(.LCPI3_0)(a0)
; RV64I-SMALL-NEXT:    fadd.s fa0, fa0, fa5
; RV64I-SMALL-NEXT:    ret
;
; RV64I-MEDIUM-LABEL: lower_constantpool:
; RV64I-MEDIUM:       # %bb.0:
; RV64I-MEDIUM-NEXT:  .Lpcrel_hi3:
; RV64I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(.LCPI3_0)
; RV64I-MEDIUM-NEXT:    flw fa5, %pcrel_lo(.Lpcrel_hi3)(a0)
; RV64I-MEDIUM-NEXT:    fadd.s fa0, fa0, fa5
; RV64I-MEDIUM-NEXT:    ret
;
; RV64I-LARGE-LABEL: lower_constantpool:
; RV64I-LARGE:       # %bb.0:
; RV64I-LARGE-NEXT:  .Lpcrel_hi3:
; RV64I-LARGE-NEXT:    auipc a0, %pcrel_hi(.LCPI3_0)
; RV64I-LARGE-NEXT:    flw fa5, %pcrel_lo(.Lpcrel_hi3)(a0)
; RV64I-LARGE-NEXT:    fadd.s fa0, fa0, fa5
; RV64I-LARGE-NEXT:    ret
  %1 = fadd float %a, 1.000244140625
  ret float %1
}

; Check lowering of extern_weaks
@W = extern_weak global i32

define i32 @lower_extern_weak(i32 %a) nounwind {
; RV32I-SMALL-LABEL: lower_extern_weak:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(W)
; RV32I-SMALL-NEXT:    lw a0, %lo(W)(a0)
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_extern_weak:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .Lpcrel_hi4:
; RV32I-MEDIUM-NEXT:    auipc a0, %got_pcrel_hi(W)
; RV32I-MEDIUM-NEXT:    lw a0, %pcrel_lo(.Lpcrel_hi4)(a0)
; RV32I-MEDIUM-NEXT:    lw a0, 0(a0)
; RV32I-MEDIUM-NEXT:    ret
;
; RV64I-SMALL-LABEL: lower_extern_weak:
; RV64I-SMALL:       # %bb.0:
; RV64I-SMALL-NEXT:    lui a0, %hi(W)
; RV64I-SMALL-NEXT:    lw a0, %lo(W)(a0)
; RV64I-SMALL-NEXT:    ret
;
; RV64I-MEDIUM-LABEL: lower_extern_weak:
; RV64I-MEDIUM:       # %bb.0:
; RV64I-MEDIUM-NEXT:  .Lpcrel_hi4:
; RV64I-MEDIUM-NEXT:    auipc a0, %got_pcrel_hi(W)
; RV64I-MEDIUM-NEXT:    ld a0, %pcrel_lo(.Lpcrel_hi4)(a0)
; RV64I-MEDIUM-NEXT:    lw a0, 0(a0)
; RV64I-MEDIUM-NEXT:    ret
;
; RV64I-LARGE-LABEL: lower_extern_weak:
; RV64I-LARGE:       # %bb.0:
; RV64I-LARGE-NEXT:  .Lpcrel_hi4:
; RV64I-LARGE-NEXT:    auipc a0, %pcrel_hi(.LCPI4_0)
; RV64I-LARGE-NEXT:    ld a0, %pcrel_lo(.Lpcrel_hi4)(a0)
; RV64I-LARGE-NEXT:    lw a0, 0(a0)
; RV64I-LARGE-NEXT:    ret
  %1 = load volatile i32, ptr @W
  ret i32 %1
}
