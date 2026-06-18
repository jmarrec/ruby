##
##  This file is part of the "Coroutine" project and released under the MIT License.
##
##  Created by Samuel Williams on 10/5/2018.
##  Copyright, 2018, by Samuel Williams.
##

#define TOKEN_PASTE(x,y) x##y
#define PREFIXED_SYMBOL(prefix,name) TOKEN_PASTE(prefix,name)

#if defined(__APPLE__)
#define x29 fp
#define x30 lr
.text
.p2align 2
#else
.text
.align 2
#endif

#if defined(_WIN32)
## Add more space for certain TEB values on each stack
#define TEB_OFFSET 0x20
#else
#define TEB_OFFSET 0x00
#endif

.global PREFIXED_SYMBOL(SYMBOL_PREFIX,coroutine_transfer)
PREFIXED_SYMBOL(SYMBOL_PREFIX,coroutine_transfer):

	# Make space on the stack for caller registers
	sub sp, sp, 0xb0 + TEB_OFFSET

	# Save caller registers
	stp d8, d9, [sp, 0x00 + TEB_OFFSET]
	stp d10, d11, [sp, 0x10 + TEB_OFFSET]
	stp d12, d13, [sp, 0x20 + TEB_OFFSET]
	stp d14, d15, [sp, 0x30 + TEB_OFFSET]
	stp x19, x20, [sp, 0x40 + TEB_OFFSET]
	stp x21, x22, [sp, 0x50 + TEB_OFFSET]
	stp x23, x24, [sp, 0x60 + TEB_OFFSET]
	stp x25, x26, [sp, 0x70 + TEB_OFFSET]
	stp x27, x28, [sp, 0x80 + TEB_OFFSET]
	stp x29, x30, [sp, 0x90 + TEB_OFFSET]

	# Save return address
	str x30, [sp, 0xa0 + TEB_OFFSET]

#if defined(_WIN32)
	# Save certain values from Thread Environment Block (TEB)
	# x18 points to the TEB on Windows
	# Read TeStackBase and TeStackLimit at ksarm64.h from TEB
	ldp  x5,  x6,  [x18, #0x08]
	# Save them
	stp  x5,  x6,  [sp, #0x00]
	# Read TeDeallocationStack at ksarm64.h from TEB
	ldr  x5, [x18, #0x1478]
	# Read TeFiberData at ksarm64.h from TEB
	ldr  x6, [x18, #0x20]
	# Save current fiber data and deallocation stack
	stp  x5,  x6,  [sp, #0x10]
#endif

	# Save stack pointer to x0 (first argument)
	mov x2, sp
	str x2, [x0, 0]

	# Load stack pointer from x1 (second argument)
	ldr x3, [x1, 0]
	mov sp, x3

#if defined(_WIN32)
	# Restore stack base and limit
	ldp  x5,  x6,  [sp, #0x00]
	# Write TeStackBase and TeStackLimit at ksarm64.h to TEB
	stp  x5,  x6,  [x18, #0x08]
	# Restore fiber data and deallocation stack
	ldp  x5,  x6,  [sp, #0x10]
	# Write TeDeallocationStack at ksarm64.h to TEB
	str  x5, [x18, #0x1478]
	# Write TeFiberData at ksarm64.h to TEB
	str  x6, [x18, #0x20]
#endif

	# Restore caller registers
	ldp d8, d9, [sp, 0x00 + TEB_OFFSET]
	ldp d10, d11, [sp, 0x10 + TEB_OFFSET]
	ldp d12, d13, [sp, 0x20 + TEB_OFFSET]
	ldp d14, d15, [sp, 0x30 + TEB_OFFSET]
	ldp x19, x20, [sp, 0x40 + TEB_OFFSET]
	ldp x21, x22, [sp, 0x50 + TEB_OFFSET]
	ldp x23, x24, [sp, 0x60 + TEB_OFFSET]
	ldp x25, x26, [sp, 0x70 + TEB_OFFSET]
	ldp x27, x28, [sp, 0x80 + TEB_OFFSET]
	ldp x29, x30, [sp, 0x90 + TEB_OFFSET]

	# Load return address into x4
	ldr x4, [sp, 0xa0 + TEB_OFFSET]

	# Pop stack frame
	add sp, sp, 0xb0 + TEB_OFFSET

	# Jump to return address (in x4)
	ret x4

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
