/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.h                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/11/17 19:45:23 by nlaporte          #+#    #+#             */
/*   Updated: 2024/11/22 03:20:56 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef GET_NEXT_LINE_H
# define GET_NEXT_LINE_H

# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 2000
# endif

# include <unistd.h>
# include <stdlib.h>
# include <stddef.h>
# include <stdint.h>

typedef struct s_file
{
	char	buf[BUFFER_SIZE + 1];
	char	*line;
	int		init;
	int		fd;
	int		status;
	int		index;
}	t_file;

void	init_file(t_file *file, int fd);
void	clear_file(t_file *file);
void	clear_buffer(t_file *file);

char	*get_next_line(int fd);
char	*ft_give_malloc(int linebreak, int size);

int		ft_getendline(char *s);
int		ft_strlen2(char *s, int endl);

#endif // !GET_NEXT_LINE_H
