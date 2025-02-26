/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_exit.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/17 11:16:09 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/17 12:42:39 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../pipex.h"

void	free_pipex(t_env pipex)
{
	int	i;

	i = 0;
	while (i < pipex.cmd_amount)
	{
		waitpid(pipex.commands[i].act_fork, NULL, 0);
		free_split(pipex.commands[i].params);
		i++;
	}
	free(pipex.commands);
}

void	exit_pipex(t_env *pipex, char *error, int err)
{
	int	i;
	int	j;

	i = 0;
	j = 0;
	(void)j;
	(void)err;
	if (error)
		ft_putendl_fd(error, 2);
	if (pipex->infile_path)
		free(pipex->infile_path);
	if (pipex->outfile_path)
		free(pipex->outfile_path);
	while (i < pipex->cmd_amount)
		free_split(pipex->commands[i++].to_free);
	free(pipex->commands);
	exit(pipex->exit_code);
}
