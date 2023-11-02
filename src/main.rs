use std::env;
use colored::Colorize;

fn usage() {
  println!("{}", "Welcome to CleanCodersGIT!".green());
  println!("Usage: ./ccg [options] [--] [file...]\n");
  println!("Arguments:");
  println!("  -h, --help");
  println!("    Display this usage message and exit.\n");
  println!("  -h <command>, --help <command>");
  println!("    Shows useful informateion about the given command.");
}

fn main() {
  let args: Vec<_> = env::args().collect();

  if args.len() > 1 {
    println!("The first argument is {}", args[1]);
  }

  usage();
}
