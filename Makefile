# LIBFT
SOURCES			= main.c src/parsing.c \
							src/gnl/get_next_line.c src/gnl/get_next_line_utils.c \
							src/pipex_struct/pipex_struct.c src/pipex_struct/pipex_exit.c \
							src/pipex_struct/pipex_file.c src/pipex_struct/pipex_utils.c \
							src/pipex_struct/pipex_file2.c
OBJECTS     = ${SOURCES:.c=.o}
NAME        = pipex 
CC          = cc
FLAGS       = -Wall -Werror -Wextra -g3
LIBFT				= libft/
GREEN				= \033[92m
BLUE				= \033[94m
ORANGE			= \033[93m
RED					= \033[91m
WHITE				= \033[0m

all: libft gnl ${NAME}

title:
	@printf  "${BLUE}"
	@cat .title

${NAME}: ${OBJECTS}
	@${CC} ${OBJECTS} -L./${LIBFT} -lft -o ${NAME}
	@printf "${GREEN}\n\n✅ Pipex pret !\n"

%.o: %.c libft
	@${CC} ${FLAGS} -I./${LIBFT} -g3 -c $< -o $@
	@printf  "\r${BLUE}✅ Compilation $< objects termine"

libft:
	@if [ -d "${LIBFT}" ]; then \
		printf "⏳ Verification de libft ...\n"; \
		(cd libft && git pull > /dev/null 2>&1); \
	else \
		printf  "${ORANGE}Pas de libft, telechargement ...${WHITE}\n"; \
		(git clone https://github.com/LAPORTENicolas/libft.git libft > /dev/null 2>&1); \
	fi
	@printf  "${GREEN}✅ Libft, a jour !\n"; \
	${MAKE} -C ${LIBFT}
	printf  ""; \

gnl:
	@if [ -f "gnl" ]; then \
		printf "⏳ Verification de gnl ...\n"; \
		(cd "gnl" && git pull > /dev/null 2>&1); \
	fi

clean:
	@printf  "${ORANGE}⏳ Supression des objetcs pipex\n"
	@rm -rf ${OBJECTS}
	@printf  "${ORANGE}⏳ Supression des objetcs libft\n"
	@if [ -d "${LIBFT}" ]; then \
		${MAKE} -C "${LIBFT}" clean > /dev/null 2>&1; \
	fi

fclean: clean
	@printf  "${ORANGE}⏳ Supression executale pipex\n"
	@if [ -d "${LIBFT}" ]; then \
		${MAKE} -C ${LIBFT} fclean > /dev/null; \
	fi
	@rm -rf ${NAME}

reset: fclean
	@printf  "${RED}⏳ Supression des sources libft\n"
	@if [ -d "${LIBFT}" ]; then \
		rm -rf libft/ > /dev/null 2>&1; \
	fi
	@printf  "${ORANGE}⏳ Supression des object + executale pipex\n"
	@rm -rf ${OBJECTS}
	@rm -rf ${NAME}
	@printf  "${GREEN}✅ Supression termine\n\n"

re: reset all

.PHONY: all clean fclean re
