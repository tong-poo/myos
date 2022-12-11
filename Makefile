C_SOURCES = $(wildcard kernel/*.c)
CPP_SOURCES = $(wildcard kernel/*.cpp)
ASM_SOURCES = kernel/isr_wrapper.asm
OBJS = $(C_SOURCES:.c=.o) $(CPP_SOURCES:.cpp=.o) $(ASM_SOURCES:.asm=.o)
HEADERS = $(wildcard include/*.h) $(wildcard include/*.hpp)
# QEMUOPTS = \
# 	-serial mon:stdio \
# 	-drive filos.iso,index=0,if=ide,format=raw \
# 	-drive file=os.iso,index=0,if=floppy,format=raw

# gcc
# CXX = i386-elf-g++
# LD = i386-elf-ld
# DBG = i386-elf-gdb
# DBGOPTS = \
# 	-ex "target remote localhost:1234"

#clang
CXX = clang++ -target i386
LD = ld.lld
DBG = lldb
DBGOPTS = \
	-o "gdb-remote localhost:1234"

CXXFLAGS = \
	-g \
	-O0 \
	-I./include \
	-nostdlib \
	-ffreestanding \
	-Wall \
	-Wextra \
	-Wno-c99-designator \
	-fno-exceptions \
	-fno-rtti \
	-fno-use-init-array \
	-std=gnu++20

.PHONY: all run debug bdebug clean bochs

all: os.iso kernel.elf

qemu: os.iso
	qemu-system-i386 -drive format=raw,file=$^

qemud: os.iso
	qemu-system-i386 -drive format=raw,file=$^ -s -S 
#	lldb kernel.elf --one-liner "gdb-remote localhost:1234"
#	gdb kernel.elf -ex "target remote localhost:1234"

os.iso: kernel.elf grubroot/boot/grub/grub.cfg
	cp kernel.elf grubroot/boot/
	grub-mkrescue -o $@ grubroot/

kernel.elf: $(OBJS) kernel/kernel.ld
	$(LD) -T kernel/kernel.ld $(OBJS) -o $@

%.bin: %.asm
	nasm -fbin $< -o $@

%.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.asm
	nasm -f elf32 $< -o $@

run: os.iso
	$(QEMU) $(QEMUOPTS)

debug: os.iso kernel/kernel.elf
#	$(QEMU) -s -S $(QEMUOPTS) & $(DBG) kernel/kernel.elf $(DBGOPTS)
	$(QEMU) -s -S $(QEMUOPTS)

clean:
	rm -f */*.bin */*.o */*.elf os.iso

hoge:
	objdump -b binary -m i386 -M intel -D kernel/kernel.binos.iso:
	dd if=/dev/zero of=$@ bs=1M count=1
	sudo losetup /dev/loop0 $@
	sudo mkfs.ext2 -I 128 /dev/loop0
	mkdir mnt
	sudo mount /dev/loop0 mnt
	sudo chmod 777 mnt

	echo "Hello, world" > mnt/hello.txt

	sudo umount mnt
	rm -r mnt
	sudo losetup -d /dev/loop0