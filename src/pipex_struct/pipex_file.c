/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_file.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/19 16:58:06 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:22:43 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../pipex.h"

void	create_file2(t_env *pipex, char **env, char *str, char **split)
{
	pid_t	tmp;

	tmp = fork();
	if (tmp == 0)
		if (execve("/bin/touch", split, env) == -1)
			exit_pipex(pipex, "Cant exec /bin/touch", 1);
	if (split)
		free_split(split);
	if (str)
		free(str);
	waitpid(tmp, NULL, 0);
}

void	create_file(t_env *pipex, char **env)
{
	char	**split;
	char	*str;
	int		i;

	i = 0;
	split = ft_split(pipex->outfile_path, '/');
	while (split[i])
		i++;
	if (ft_strlen(split[i - 1]) > 255)
	{
		if (split)
			free_split(split);
		pipex->exit_code = 1;
		exit_pipex(pipex, "Aie aie aie", 1);
	}
	free_split(split);
	str = malloc(sizeof(char) * (ft_strlen(pipex->outfile_path) + 11));
	if (!str)
		exit_pipex(pipex, "Malloc echec str", 1);
	ft_memset(str, 0, ft_strlen(pipex->outfile_path) + 7);
	ft_strlcat(str, "touch ", 7);
	ft_strlcat(str, pipex->outfile_path, ft_strlen(pipex->outfile_path) + 7);
	split = ft_split(str, ' ');
	create_file2(pipex, env, str, split);
}

void	manage_output_file(t_env *pipex, char **env)
{
	int	fd;

	if (access(pipex->outfile_path, W_OK) == 0)
	{
		fd = open(pipex->outfile_path, O_WRONLY | O_TRUNC);
		if (fd == -1)
			exit_pipex(pipex, NULL, 1);
		dup2(fd, STDOUT_FILENO);
		close(fd);
	}
	else
	{
		create_file(pipex, env);
		fd = open(pipex->outfile_path, O_WRONLY | O_TRUNC);
		if (fd == -1)
		{
			ft_printerror(NULL);
			pipex->exit_code = 1;
			exit_pipex(pipex, NULL, 1);
		}
		pipex->exit_code = 0;
		dup2(fd, STDOUT_FILENO);
		close(fd);
	}
}

int	manage_input_file(t_env *pipex)
{
	int	fd;

	if (pipex->infile_path && access(pipex->infile_path, R_OK) == 0)
	{
		pipex->input = 0;
		fd = open(pipex->infile_path, O_RDONLY);
		if (fd == -1)
			exit_pipex(pipex, "manage input file: open error", 1);
		dup2(fd, STDIN_FILENO);
		close(fd);
		return (0);
	}
	else
	{
		ft_printerror(NULL);
		pipex->input = -1;
	}
	return (1);
}
