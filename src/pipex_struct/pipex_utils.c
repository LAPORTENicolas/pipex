/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_utils.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/19 17:02:45 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:03:01 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../pipex.h"

void	init_pipex(int ac, char **av, t_env *pipex)
{
	int	i;

	pipex->cmd_amount = ac - 1;
	pipex->commands = malloc(sizeof(t_cmd) * pipex->cmd_amount);
	i = 0;
	while (i < pipex->cmd_amount)
	{
		pipex->commands[i].params = ft_split(av[i + 1], ' ');
		i++;
	}
}

int	get_file(char *path)
{
	if (access(path, W_OK) == -1)
		return (-1);
	return (open(path, O_WRONLY));
}

void	ft_printerror(char *str)
{
	ft_putstr_fd("Pipex: ", 2);
	if (str)
	{
		ft_putstr_fd(str, 2);
		ft_putstr_fd(" : ", 2);
	}
	ft_putendl_fd(strerror(errno), 2);
}

int	wait_pipex(void)
{
	pid_t	pid[2];
	int		status;
	int		end;

	pid[0] = wait(&status);
	pid[1] = 0;
	while (pid[0] > 0)
	{
		if (pid[1] == 0 || (pid[0] > pid[1]))
		{
			end = (status >> 8) & 0xff;
			pid[1] = pid[0];
		}
		pid[0] = wait(&status);
	}
	return (end);
}
