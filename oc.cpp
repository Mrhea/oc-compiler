/*
 * main.cpp
 * Author: Matthew Rhea
 * CruzID: Mrhea
 */

#include <string>
#include <iostream>
using namespace std;

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wait.h>
#include <libgen.h>
#include <unistd.h>

#include "string_set.h"
#include "aux_lib.h"
#include "lyutils.h"
#include "astree.h"

string CPP = "/usr/bin/cpp -nostdinc";
int exit_status;
constexpr size_t LINESIZE = 1024;
FILE* str_File; 
FILE* tok_File;
FILE* ast_File;
string_set stringset;
int parse_rc;

void chomp (char* string, char delim) {
  size_t len = strlen (string);
  if (len == 0) return;
  char* nlpos = string + len - 1;
  if (*nlpos == delim) *nlpos = '\0';
}

void cpplines(FILE* pipe, const char* filename) {
  int linenr = 1;
  char inputname[LINESIZE];
  strcpy (inputname, filename);
  for (;;) {
    char buffer[LINESIZE];
    char* fgets_rc = fgets (buffer, LINESIZE, pipe);
    if (fgets_rc == nullptr) break;
    chomp (buffer, '\n');
    int sscanf_rc = sscanf (buffer, "# %d \"%[^\"]\"",
                            &linenr, inputname);
    if(sscanf_rc == 2) {
      continue;
    }
    char* savepos = nullptr;
    char* bufptr = buffer;
    for (int tokenct = 1;; ++tokenct) {
      char* token = strtok_r (bufptr, " \t\n", &savepos);
      bufptr = nullptr;
      if (token == nullptr) break;
      string_set::intern(token);
    }
    parse_rc = yyparse();
    astree::print(ast_File, parser::root);
    ++linenr;
  }
}

void format_files(const char* filename) {
  // Format filenames
  string file_string = string(filename);

  string str_filename = file_string.substr(0,
      file_string.size()-3)+ ".str";
  string tok_filename = file_string.substr(0,
      file_string.size()-3)+ ".tok";
  string ast_filename = file_string.substr(0,
      file_string.size()-3)+ ".ast";

  // Open file pointers
  str_File = fopen(str_filename.c_str(), "w+");
  tok_File = fopen(tok_filename.c_str(), "w+");
  ast_File = fopen(ast_filename.c_str(), "w+");

  // File pointer error checking
  if (str_File == NULL) {
      syserrprintf(str_filename.c_str());
      exit_status = EXIT_FAILURE;
  }
  if (tok_File == NULL) {
      syserrprintf(tok_filename.c_str());
      exit_status = EXIT_FAILURE;
  }
  if (ast_File == NULL) {
      syserrprintf(ast_filename.c_str());
      exit_status = EXIT_FAILURE;
  }

  cpplines(yyin, filename);
  string_set::dump(str_File);
}


void cpp_popen (const char* filename) {
   string cpp_command = CPP + " " + filename;
   yyin = popen (cpp_command.c_str(), "r");
   if (yyin == nullptr) {
      syserrprintf (cpp_command.c_str());
      exit (exec::exit_status);
   }else {
      if (yy_flex_debug) {
         fprintf (stderr, "-- popen (%s), fileno(yyin) = %d\n",
                  cpp_command.c_str(), fileno (yyin));
      }
      lexer::newfilename (cpp_command);
      format_files(filename);
   }
}

void scan_opts (int argc, char** argv) {
   opterr = 0;
   yy_flex_debug = 0;
   yydebug = 0;
   lexer::interactive = isatty (fileno (stdin))
                    and isatty (fileno (stdout));
   for(;;) {
      int opt = getopt (argc, argv, "@:ly");
      if (opt == EOF) break;
      switch (opt) {
         case '@': set_debugflags (optarg);   break;
         case 'l': yy_flex_debug = 1;         break;
         case 'y': yydebug = 1;               break;
         default:  errprintf ("Unrecognized option (%c)\n", optopt); break;
      }
   }
   if (optind > argc) {
      errprintf ("Usage: %s [-ly] [filename]\n",
                 exec::execname.c_str());
      exit (exec::exit_status);
   }
   const char* filename = optind == argc ? "-" : argv[optind];
   cpp_popen (filename);
}

void cpp_pclose() {
   int pclose_rc = pclose (yyin);
   eprint_status (CPP.c_str(), pclose_rc);
   if (pclose_rc != 0) exec::exit_status = EXIT_FAILURE;
}

void close_files() {
  fclose(str_File);
  fclose(tok_File);
  fclose(ast_File);
}

int main(int argc, char** argv) {
  exec::execname = basename(argv[0]);
  exit_status = EXIT_SUCCESS;

  // Some debugging and error checking code
  if (yydebug or yy_flex_debug) {
    fprintf (stderr, "Command:");
    for (char** arg = &argv[0]; arg < &argv[argc]; ++arg) {
          fprintf (stderr, " %s", *arg);
    }
    fprintf (stderr, "\n");
  }
      
  // Scan for option flags
  scan_opts(argc, argv); 

  // Close pipe
  cpp_pclose();

  // Free resources used by scanner
  yylex_destroy();

  if (yydebug or yy_flex_debug) {
    fprintf (stderr, "Dumping parser::root:\n");
    if (parser::root != nullptr) parser::root->dump_tree (stderr);
    fprintf (stderr, "Dumping string_set:\n");
    string_set::dump (stderr);
  }
  if (parse_rc) {
    errprintf ("parse failed (%d)\n", parse_rc);
  }else {
    delete parser::root;
  }

  close_files();
  return exec::exit_status;

}

