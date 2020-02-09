DEPS:=glfw3 cglm stb portaudio glad
FLAGS:=-Wall --std=c11 -g -lGL
FILES_PC=$(shell find . -name "*.pc")
DEP_FLAGS=$(foreach f,${FILES_PC},\
	$(strip $(shell \
		pkg-config --with-path=$(dir $f) --cflags --libs --static $(notdir ${f:.pc=}) \
	)) \
)
BINS=$(foreach f,$(wildcard src/*.c),bin/$(notdir ${f:.c=}))
INCLUDES=-Iincludes $(foreach f,$(filter-out %/test/include %/cpp/include,$(shell find . -type d -name "include")),-I$f)
LIBS_STATIC=$(foreach f,$(shell find . -name "*.a"),-L$(dir $f) $f)

all: ${DEPS} ${BINS}

glfw3:
	git clone https://github.com/glfw/glfw $@
	cd $@ && git checkout latest && cmake . && make

portaudio:
	git clone https://git.assembla.com/portaudio.git $@
	cd $@ && git checkout pa_stable_v190600_20161030 && \
		cmake . && make

cglm:
	git clone https://github.com/recp/cglm $@
	cd $@ && git checkout v0.6.2 && sh autogen.sh && sh configure && make

stb:
	git clone https://github.com/nothings/stb $@
	[ -d includes ] || mkdir includes
	cd $@ && ln -sfr stb_image.h ../includes/stb_image.h && \
		ln -sfr stb_truetype.h ../includes/stb_truetype.h

glad:
	git clone https://github.com/Dav1dde/glad
	python -m glad --generator=c --out-path='GL'

bin/% : src/%.c GL/src/glad.c Makefile | bin
	gcc $(filter %.c,$^) -o $@ ${FLAGS} ${LIBS_STATIC} ${INCLUDES} $(filter-out -lcglm,${DEP_FLAGS})


.PHONY: clean

bin:
	mkdir $@

clean:
	rm -rf ${DEPS}

# pkg-config --with-path="{root}" --cflags --libs --static {name}
#					)
#					for token in shlex.split(out):
#						if token in SEEN:
#							continue
#						FLAGS.append(token)
#	FLAGS = ' '.join(FLAGS)
#	DIR_SRC, DIR_BIN = ['src','bin']
#	sources = [Path(f) for f in os.listdir(DIR_SRC)]
#	bins = [s.f('.', 1) for f in sources]
#
#	out = [
#		f"FLAGS={FLAGS}",
#		'',
#	]
#	with open('Makefile', 'w') as fh:
#		fh.write(os.linesep.join(out))
#
#
#if __name__ == "__main__":
#	args = sys.argv[1:]
#	if 'clean' in args:
#		for dep in DEPS:
#			dest = Path(dep[0])
#			if dest.is_dir():
#				shutil.rmtree(dest)
#	else:
#		main()
