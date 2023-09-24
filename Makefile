UK_ROOT ?= $(PWD)/.unikraft/unikraft
UK_LIBS ?= $(PWD)/.unikraft/libs

LIBS := $(UK_LIBS)/newlib:$(UK_LIBS)/duktape

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
