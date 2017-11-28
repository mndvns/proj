#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <iostream>
#include "stdlib.h"

#include "../src/ls.h"

using std::cout;
using std::endl;

int
main (int argc, char **argv)
{
  gengetopt_args_info args_info;

  if (cmdline_parser (argc, argv, &args_info) != 0)
    exit(1) ;

  cout << args_info.limit_arg
       << " " << args_info.fullpath_flag
       << " " << args_info.oneline_flag
       << " " << args_info.grid_flag
       << " " << args_info.long_flag
       << endl;

  cmdline_parser_free (&args_info);

  return 0;
}
