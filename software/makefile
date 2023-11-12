#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The top part of this file contains all the application-specific config
# settings.  Everything beyond that is generic and will be the same for
# every application you use this makefile template for.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#-----------------------------------------------------------------------------
# This is the base name of the executable file
#-----------------------------------------------------------------------------
EXE = rdma_loop 


#-----------------------------------------------------------------------------
# This is a list of directories that have compilable code in them.  If there
# are no subdirectories, this line is must SUBDIRS = .
#-----------------------------------------------------------------------------
SUBDIRS = .


#-----------------------------------------------------------------------------
# For x86, declare whether to emit 32-bit or 64-bit code
#-----------------------------------------------------------------------------
X86_TYPE = 64


#-----------------------------------------------------------------------------
# These are the language standards we want to compile with
#-----------------------------------------------------------------------------
C_STD = -std=gnu99
CPP_STD = -std=c++17


#-----------------------------------------------------------------------------
# Declare the compile-time flags that are common between all platforms
#-----------------------------------------------------------------------------
CXXFLAGS =	\
-O2 -g -Wall \
-c -fmessage-length=0 \
-D_GNU_SOURCE \
-Wno-sign-compare \
-Wno-unused-value

#-----------------------------------------------------------------------------
# Link options
#-----------------------------------------------------------------------------
LINK_FLAGS = -pthread -lm -lrt


#-----------------------------------------------------------------------------
# If there is no target on the command line, this is the target we use
#-----------------------------------------------------------------------------
.DEFAULT_GOAL := x86

#-----------------------------------------------------------------------------
# Define the name of the compiler and what "build all" means for our platform
#-----------------------------------------------------------------------------
ALL       = x86 
X86_CC    = $(CC)
X86_CXX   = $(CXX)
X86_STRIP = strip


#-----------------------------------------------------------------------------
# Declare where the object files get created
#-----------------------------------------------------------------------------
X86_OBJ_DIR := obj_x86


#-----------------------------------------------------------------------------
# Always run the recipe to make the following targets
#-----------------------------------------------------------------------------
.PHONY: $(X86_OBJ_DIR) 


#-----------------------------------------------------------------------------
# We're going to compile every .c and .cpp file in each directory
#-----------------------------------------------------------------------------
C_SRC_FILES   := $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.c))
CPP_SRC_FILES := $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.cpp))


#-----------------------------------------------------------------------------
# In the source files, normalize "./filename" to just "filename"
#-----------------------------------------------------------------------------
C_SRC_FILES   := $(subst ./,,$(C_SRC_FILES))
CPP_SRC_FILES := $(subst ./,,$(CPP_SRC_FILES))


#-----------------------------------------------------------------------------
# Create the base-names of the object files
#-----------------------------------------------------------------------------
C_OBJ     := $(C_SRC_FILES:.c=.o)
CPP_OBJ   := $(CPP_SRC_FILES:.cpp=.o)
OBJ_FILES := ${C_OBJ} ${CPP_OBJ}


#-----------------------------------------------------------------------------
# We are going to keep x86 and ARM object files in separate sub-directories
#-----------------------------------------------------------------------------
X86_OBJS := $(addprefix $(X86_OBJ_DIR)/,$(OBJ_FILES))


#-----------------------------------------------------------------------------
# This rules tells how to compile an X86 .o object file from a .cpp source
#-----------------------------------------------------------------------------
$(X86_OBJ_DIR)/%.o : %.cpp
	$(X86_CXX) -m$(X86_TYPE) $(CPPFLAGS) $(CPP_STD) $(CXXFLAGS) -c $< -o $@

$(X86_OBJ_DIR)/%.o : %.c
	$(X86_CC) -m$(X86_TYPE) $(CPPFLAGS) $(C_STD) $(CXXFLAGS) -c $< -o $@


#-----------------------------------------------------------------------------
# This rule builds the x86 executable from the object files
#-----------------------------------------------------------------------------
$(EXE) : $(X86_OBJS)
	$(X86_CXX) -m$(X86_TYPE) -o $@ $(X86_OBJS) $(LINK_FLAGS)
	$(X86_STRIP) $(EXE)


#-----------------------------------------------------------------------------
# This target builds all executables supported by this platform
#-----------------------------------------------------------------------------
all:	$(ALL)


#-----------------------------------------------------------------------------
# This target builds just the x86 executable
#-----------------------------------------------------------------------------
x86:	$(X86_OBJ_DIR) $(EXE)


#-----------------------------------------------------------------------------
# These targets makes all neccessary folders for object files
#-----------------------------------------------------------------------------
$(X86_OBJ_DIR):
	@for subdir in $(SUBDIRS); do \
	    mkdir -p -m 777 $(X86_OBJ_DIR)/$$subdir ;\
	done


#-----------------------------------------------------------------------------
# This target removes all files that are created at build time
#-----------------------------------------------------------------------------
clean:
	rm -rf Makefile.bak makefile.bak $(EXE).tgz $(EXE) 
	rm -rf $(X86_OBJ_DIR) 


#-----------------------------------------------------------------------------
# This target creates a compressed tarball of the source code
#-----------------------------------------------------------------------------
tarball:	clean
	rm -rf $(EXE).tgz
	tar --create --exclude-vcs -v -z -f $(EXE).tgz *


#-----------------------------------------------------------------------------
# This target appends/updates the dependencies list at the end of this file
#-----------------------------------------------------------------------------
depend:
	@makedepend    -p$(X86_OBJ_DIR)/ $(C_SRC_FILES) $(CPP_SRC_FILES) -Y 2>/dev/null


#-----------------------------------------------------------------------------
# Convenience target for displaying makefile variables 
#-----------------------------------------------------------------------------
debug:
	@echo "SUBDIRS       = ${SUBDIRS}"
	@echo "C_SRC_FILES   = ${C_SRC_FILES}"
	@echo "CPP_SRC_FILES = ${CPP_SRC_FILES}"
	@echo "C_OBJ         = ${C_OBJ}"
	@echo "CPP_OBJ       = ${CPP_OBJ}"
	@echo "OBJ_FILES     = ${OBJ_FILES}"


#-----------------------------------------------------------------------------




