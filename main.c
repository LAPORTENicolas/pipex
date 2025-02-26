/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/11 15:40:19 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:22:59 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft/ft_printf/ft_printf.h"
#include "libft/libft.h"
#include "pipex.h"
#include "src/gnl/get_next_line.h"
#include <unistd.h>

void	main_utils(t_env *pipex)
{
	char	*str;
	int		fd;

	fd = open(pipex->outfile_path, R_OK | W_OK);
	if (fd != -1)
	{
		str = get_next_line(fd);
		if (!str)
		{
			close(fd);
			pipex->exit_code = 1;
			exit_pipex(pipex, NULL, 1);
		}
		else
			free(str);
		close(fd);
	}
}

void	read_stdin(t_env *pipex, char *limiter)
{
	char	*str;

	pipex->input = -2;
	str = NULL;
	while (1)
	{
		if (str)
		{
			if (ft_strncmp(str, limiter, ft_strlen(limiter)) == 0)
			{
				free(str);
				break ;
			}
			write(pipex->commands[0].pipefd[1], str, ft_strlen(str));
			free(str);
		}
		str = get_next_line(STDIN_FILENO);
	}
}

int	main(int ac, char **av, char **env)
{
	t_env	pipex;
	int		i;

	i = 0;
	if (ac <= 4)
		exit(1);
	ft_memset(&pipex, 0, sizeof(t_env));
	parsing(ac, av, &pipex);
	while (i < pipex.cmd_amount)
		if (pipe(pipex.commands[i++].pipefd) == -1)
			exit_pipex(&pipex, "Pipe error", 1);
	if (ft_strncmp(av[1], "here_doc", 9) == 0)
		read_stdin(&pipex, av[2]);
	if (!pipex.outfile_path)
		pipex.outfile_path = ft_strdup(av[ac - 1]);
	pipex.exit_code = logic_pipex(&pipex, env);
	exit_pipex(&pipex, NULL, 1);
	return (0);
}
