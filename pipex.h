/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nlaporte <nlaporte@student.42>             +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/16 07:43:19 by nlaporte          #+#    #+#             */
/*   Updated: 2025/02/19 17:17:44 by nlaporte         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include "libft/libft.h"
# include "src/gnl/get_next_line.h"
# include <stdlib.h>
# include <string.h>
# include <errno.h>
# include <fcntl.h>
# include <sys/wait.h>

typedef struct s_cmd
{
	pid_t	act_fork;
	char	*cmd;
	char	**params;
	char	**to_free;
	int		pipefd[2];
}	t_cmd;

typedef struct s_env
{
	t_cmd	*commands;
	char	*infile_path;
	char	*outfile_path;
	int		cmd_amount;
	int		input;
	int		exit_code;
}	t_env;

void	init_pipex(int ac, char **av, t_env *pipex);
void	create_file(t_env *pipex, char **env);
void	free_pipex(t_env pipex);
void	parsing(int ac, char **av, t_env *pipex);
void	exit_pipex(t_env *pipex, char *error, int err);
void	create_file(t_env *pipex, char **env);
void	manage_output_file(t_env *pipex, char **env);
void	ft_printerror(char *str);
void	init_pipex(int ac, char **av, t_env *pipex);
void	ft_printerror(char *str);
void	manage_output_file2(t_env *pipex, char **env);
int		wait_pipex(void);
int		get_file(char *path);
int		manage_input_file(t_env *pipex);
int		logic_pipex(t_env *pipex, char **env);

#endif // !PIPEX_H
