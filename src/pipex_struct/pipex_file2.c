/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_file2.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/21 19:49:26 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/21 19:58:43 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../pipex.h"

void	manage_output_file2(t_env *pipex, char **env)
{
	int	fd;

	if (access(pipex->outfile_path, R_OK | W_OK) == -1)
		create_file(pipex, env);
	fd = open(pipex->outfile_path, O_WRONLY | O_RDONLY | O_APPEND);
	if (fd == -1)
		exit_pipex(pipex, NULL, 1);
	dup2(fd, STDOUT_FILENO);
	close(fd);
}
