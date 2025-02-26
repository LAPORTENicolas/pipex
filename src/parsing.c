/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parsing.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/17 09:40:27 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:08:41 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../pipex.h"

static void	get_file_parsing(int ac, char **av, t_env *pipex)
{
	char	*infile;
	char	*outfile;
	size_t	infile_len;
	size_t	outfile_len;

	infile_len = ft_strlen(av[1]);
	outfile_len = ft_strlen(av[ac -1]);
	if (infile_len > 0 && infile_len < 256)
	{
		infile = ft_strdup(av[1]);
		if (!infile)
			exit_pipex(pipex, NULL, 1);
		pipex->infile_path = infile;
	}
	else
		pipex->infile_path = NULL;
	if (outfile_len > 0 && outfile_len < 256)
	{
		outfile = ft_strdup(av[ac - 1]);
		if (!outfile)
			exit_pipex(pipex, NULL, 1);
		pipex->outfile_path = outfile;
	}
	if (outfile_len <= 0)
		pipex->outfile_path = NULL;
}

static void	get_function(int ac, char **av, t_env *pipex)
{
	char	**tmp;
	int		i;

	i = 2;
	while (i++ < ac - 1)
		NULL;
	pipex->cmd_amount = i - 3;
	pipex->commands = ft_calloc(pipex->cmd_amount, sizeof(t_cmd));
	if (!pipex->commands)
		exit_pipex(pipex, NULL, 1);
	i = 0;
	while (i < pipex->cmd_amount)
	{
		tmp = ft_split(av[i + 2], ' ');
		pipex->commands[i].to_free = tmp;
		if (*tmp)
			pipex->commands[i].cmd = tmp[0];
		if (*tmp && tmp[1] != 0)
			pipex->commands[i].params = &tmp[1];
		else
			pipex->commands[i].params = NULL;
		i++;
	}
}

static void	get_function2(int ac, char **av, t_env *pipex)
{
	char	**tmp;
	int		i;

	i = 3;
	while (i++ < ac - 1)
		NULL;
	pipex->cmd_amount = i - 4;
	pipex->commands = ft_calloc(pipex->cmd_amount, sizeof(t_cmd));
	if (!pipex->commands)
		exit_pipex(pipex, NULL, 1);
	i = 0;
	while (i < pipex->cmd_amount)
	{
		tmp = ft_split(av[i + 2], ' ');
		pipex->commands[i].to_free = tmp;
		if (*tmp)
			pipex->commands[i].cmd = tmp[0];
		if (*tmp && tmp[1] != 0)
			pipex->commands[i].params = &tmp[1];
		else
			pipex->commands[i].params = NULL;
		i++;
	}
}

void	parsing(int ac, char **av, t_env *pipex)
{
	get_file_parsing(ac, av, pipex);
	if (pipex->input == -2)
		get_function2(ac, av, pipex);
	else
		get_function(ac, av, pipex);
}
