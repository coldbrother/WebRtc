#指定交叉编译工具
CC      = gcc
AS      = $(CROSS_COMPILE)as  
LD      = $(CROSS_COMPILE)ld  
CC      = $(CROSS_COMPILE)gcc  
CPP     = $(CC) -E  
AR      = $(CROSS_COMPILE)ar  
NM      = $(CROSS_COMPILE)nm

#获取工程的根目录的全路径
SOURCE_ROOT = $(shell pwd)
 
CFLAGS		:= -Wall -O2 -fno-builtin
CPPFLAGS	:= 
 
#-I是指定头文件的意思，所以这里是将所有的头文件的变量都包含在 INCLUDE_DIR 变量中
INCLUDE_DIR := -I $(SOURCE_ROOT)/ 
	
 
#生成的目标的库文件名称是mylib.so
APP_NAME=webrtclib.so
 
#将所有的.c文件都包含在APP_OBJECTC中，当然这里肯定还有其他的方法，我这里
#的效率肯定不是特别高
all: $(APP_NAME)
APP_OBJECTC += 	analog_agc.c  
APP_OBJECTC +=	get_scaling_square.c   
APP_OBJECTC +=	resample_by_2_internal.c 
APP_OBJECTC +=	complex_bit_reverse.c   
APP_OBJECTC +=	min_max_operations.c  
APP_OBJECTC +=	resample_by_2_mips.c  
APP_OBJECTC +=	complex_fft.c         
APP_OBJECTC +=	noise_suppression.c   
APP_OBJECTC +=	resample.c           
APP_OBJECTC +=	copy_set_operations.c 
APP_OBJECTC +=	noise_suppression_x.c  
APP_OBJECTC +=	resample_fractional.c   
APP_OBJECTC +=	cross_correlation.c   
APP_OBJECTC +=	ns_core.c     
APP_OBJECTC +=	ring_buffer.c 
APP_OBJECTC +=	digital_agc.c  
APP_OBJECTC +=	nsx_core.c        
APP_OBJECTC +=	spl_init.c   
APP_OBJECTC +=	division_operations.c   
APP_OBJECTC +=	nsx_core_c.c           
APP_OBJECTC +=	splitting_filter.c 
APP_OBJECTC +=	dot_product_with_scale.c  
APP_OBJECTC +=	nsx_core_neon_offsets.c 
APP_OBJECTC +=	spl_sqrt.c    
APP_OBJECTC +=	downsample_fast.c  
APP_OBJECTC +=	real_fft.c    
APP_OBJECTC +=	spl_sqrt_floor.c 
APP_OBJECTC +=	energy.c    
APP_OBJECTC +=	resample_48khz.c   
APP_OBJECTC +=	vector_scaling_operations.c 
APP_OBJECTC +=	fft4g.c 
APP_OBJECTC +=	resample_by_2.c 
APP_OBJECTC +=  api.c

#介绍一下 patsubst，
#patsubst：扩展通配符
#作用： $(patsubst %.c,%.o,$(dir) )中，patsubst把$(dir)中的变量符合后缀是.c的全部替换成.o
#所以，本例中，patsubst把 $(APP_OBJECTC)中的复合.c的全部替换成.o
STATIC_OBJ_O  = $(patsubst %.c, %.o, $(APP_OBJECTC))
 
#再介绍一下 foreach 函数
#作用：这个函数是用来做循环用的
#例如：$(foreach <var>,<list>,<text>)
#这个函数的意思是，把参数<list>;中的单词逐一取出放到参数<var>;所指定的变量中，然后再执行< #text>;所包含的表达式。每一次<text>;会返回一个字符串，循环过程中，<text>;的所返回的每个字符串会#以空格分隔，最后当整个循环结束时，<text>;所返回的每个字符串所组成的整个字符串（以空格分隔）将会
#是foreach函数的返回值。
#所以，本例中，就是将STATIC_OBJ_O中所有的.o文件取出来放到STATIC_OBJ_C中，每个.o文件以空格间隔
 
STATIC_OBJ_C  = $(foreach file, $(STATIC_OBJ_O), $(file) )
 
#下面：目标是.o文件，依赖是.c文件
#-fPIC的作用是：告诉编译器，产生位置无关码
$(STATIC_OBJ_C) : %.o:%.c 
	$(CC)  $(INCLUDE_DIR) $(CPPFLAGS) -c  -fPIC $(APP_OBJECTC)
 
#下面：目标是.so，依赖是.o文件
#-shared的作用就是制定成才.so文件
$(APP_NAME): $(STATIC_OBJ_C)	
	$(CC) -shared -o $(APP_NAME) ./*.o
	
clean:
	@rm -f *.o *.so
.PHONY: clean	
