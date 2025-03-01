/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_struct.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/16 09:14:02 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:15:12 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../pipex.h"
#include <unistd.h>

char	*get_command(char *path)
{
	char	*str;
	int		i;

	i = 0;
	if (!path)
		return (NULL);
	while (path[i])
		if (path[i++] == '/')
			return (ft_strdup(path));
	str = ft_calloc(ft_strlen(path) + 6, sizeof(char));
	if (!str)
		return (NULL);
	ft_strlcat(str, "/bin/", 6);
	ft_strlcat(str, path, ft_strlen(path) + 6);
	return (str);
}

void	exec_cmd(t_env *pipex, int i, char **env)
{
	char	*tmp;

	if (!pipex->commands[i].to_free[0] && i == pipex->cmd_amount - 1)
	{
		pipex->exit_code = 127;
		exit_pipex(pipex, NULL, 1);
	}
	tmp = get_command(pipex->commands[i].cmd);
	if (!tmp)
		exit_pipex(pipex, NULL, 1);
	if (execve(tmp, pipex->commands[i].to_free, env) == -1)
	{
		if (i == pipex->cmd_amount - 1 && \
			ft_strncmp("read", pipex->commands[i].cmd, 5) != 0)
			pipex->exit_code = 127;
		free(tmp);
		ft_printerror(pipex->commands[i].cmd);
		exit_pipex(pipex, NULL, 1);
	}
	free(tmp);
	exit(1);
}

void	fork_pipe(t_env *pipex, int i)
{
	int	fd;

	if (pipex->input == -1 && i == 1)
	{
		fd = open("/dev/null", O_RDONLY);
		dup2(fd, STDIN_FILENO);
		close(fd);
	}
	else if (i == 0)
	{
		dup2(pipex->commands[0].pipefd[1], STDIN_FILENO);
		close(pipex->commands[0].pipefd[1]);
	}
	else
	{
		dup2(pipex->commands[i - 1].pipefd[0], STDIN_FILENO);
		close(pipex->commands[i - 1].pipefd[0]);
	}
}

void	fork_pipex(t_env *pipex, char **env, int i)
{
	if (i > 0 || pipex->input == -2)
		fork_pipe(pipex, i);
	if (i < pipex->cmd_amount - 1)
		dup2(pipex->commands[i].pipefd[1], STDOUT_FILENO);
	else if (pipex->input == -2)
		manage_output_file2(pipex, env);
	else
		manage_output_file(pipex, env);
	close(pipex->commands[i].pipefd[0]);
	close(pipex->commands[i].pipefd[1]);
	exec_cmd(pipex, i, env);
	exit(127);
}

int	logic_pipex(t_env *pipex, char **env)
{
	int	i;

	if (pipex->input == -2)
		i = 0;
	else
		i = manage_input_file(pipex);
	pipex->exit_code = 0;
	while (i < pipex->cmd_amount)
	{
		pipex->commands[i].act_fork = fork();
		if (pipex->commands[i].act_fork == -1)
			exit_pipex(pipex, "Fork error", 1);
		if (pipex->commands[i].act_fork == 0)
			fork_pipex(pipex, env, i);
		if (i > 0)
			close(pipex->commands[i - 1].pipefd[0]);
		if (i < pipex->cmd_amount - 1)
			close(pipex->commands[i].pipefd[1]);
		i++;
	}
	return (wait_pipex());
}
